import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:trip/admin/adminCollction/attractionSite.dart';
import 'package:trip/root_pages/userhome/seedetails.dart';

class SearchAttractionSitesPage extends StatefulWidget {
  final String userKey;

  const SearchAttractionSitesPage({Key? key, required this.userKey}) : super(key: key);

  @override
  State<SearchAttractionSitesPage> createState() => _SearchAttractionSitesPageState();
}

class _SearchAttractionSitesPageState extends State<SearchAttractionSitesPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedState;
  List<AttractionSite> _attractionSites = [];
  List<AttractionSite> _filteredSites = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _categories = [
    "Historical Sites",
    "Cultural Heritage",
    "Natural Attractions",
    "Religious Sites",
    "Adventure & Outdoor Activities",
    "Parks & Gardens",
    "Beaches & Resorts",
    "Shopping & Souqs",
    "Cultural Festivals & Events",
    "Modern Attractions",
    "Wildlife & Eco-tourism",
    "Arts & Entertainment",
    "Sports & Recreation",
    "Health & Wellness"
  ];
  final List<String> _states = ['Muscat', 'Muttrah', 'Seeb', 'Bawshar', 'Al Amerat', 'Qurayyat'];

  @override
  void initState() {
    super.initState();
    _fetchAttractionSites();
  }

  Future<void> _fetchAttractionSites() async {
    try {
      final DatabaseReference attractionRef =
      FirebaseDatabase.instance.ref().child('AttractionSites').child('Muscat'); // Adjust for multiple states

      final snapshot = await attractionRef.get();
      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _attractionSites = data.entries
              .where((entry) => entry.value is Map) // Filter only map entries
              .map((entry) {
            return AttractionSite(
              siteName: entry.value['siteName'] ?? 'Unknown Site',
              siteImage: entry.value['siteImage'] ?? '', // Default to an empty string
              category: entry.value['category'] ?? 'Unknown Category',
              state: entry.value['state'] ?? 'Unknown State',
              rating: (entry.value['rating'] as num?)?.toDouble() ?? 0.0, // Handle missing or invalid rating
              description: entry.value['description'] ?? 'No description available.',
              latitude: (entry.value['latitude'] as num?)?.toDouble() ?? 0.0,
              longitude: (entry.value['longitude'] as num?)?.toDouble() ?? 0.0,
              key: entry.key,
            );
          }).toList();
          _filteredSites = _attractionSites;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "No attraction sites available.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error fetching attraction sites: $e";
        _isLoading = false;
      });
    }
  }

  void _filterResults() {
    String searchText = _searchController.text.toLowerCase();

    setState(() {
      _filteredSites = _attractionSites.where((site) {
        bool matchesCategory =
            _selectedCategory == null || site.category.toLowerCase() == _selectedCategory!.toLowerCase();
        bool matchesState =
            _selectedState == null || site.state.toLowerCase() == _selectedState!.toLowerCase();
        bool matchesSearch = searchText.isEmpty || site.siteName.toLowerCase().contains(searchText);
        return matchesCategory && matchesState && matchesSearch;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _selectedState = null;
      _filteredSites = List.from(_attractionSites); // Reset to initial list of sites
    });
  }

  void _navigateToDetails(AttractionSite site) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserSiteDetailsPage(site: site, userKey: widget.userKey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Attraction Sites'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Material(
              elevation: 3,
              borderRadius: BorderRadius.circular(10),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name...',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: _clearFilters,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
                onChanged: (text) => _filterResults(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    isExpanded: true,
                    value: _selectedCategory,
                    items: _categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                      _filterResults();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'State',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    isExpanded: true,
                    value: _selectedState,
                    items: _states.map((state) {
                      return DropdownMenuItem(
                        value: state,
                        child: Text(
                          state,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedState = value;
                      });
                      _filterResults();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            )
                : _filteredSites.isEmpty
                ? const Center(
              child: Text(
                'No results found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _filteredSites.length,
              itemBuilder: (context, index) {
                final site = _filteredSites[index];
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          site.siteImage.isNotEmpty
                              ? site.siteImage
                              : 'https://via.placeholder.com/60', // Fallback image
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        site.siteName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '${site.state} • ${site.category}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      onTap: () => _navigateToDetails(site),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
