import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/destination.dart';

String _img(String id) => 'https://images.unsplash.com/$id?w=1000&q=80';

class DestinationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Destination>> fetchDestinations() async {
    try {
      // 1. On tente de récupérer les données depuis Firestore
      final snapshot = await _firestore.collection('destinations').get();

      // 2. Si Firestore contient des destinations (ajoutées par l'Admin), on les utilise
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          return Destination(
            id: doc.id,
            name: data['name'] ?? 'Sans nom',
            country: data['country'] ?? 'Inconnu',
            flag: data['flag'] ?? '🌍',
            continent: data['continent'] ?? 'Monde',
            category: data['category'] ?? 'Ville',
            image: data['image'] ?? 'https://via.placeholder.com/400',
            description: data['description'] ?? 'Aucune description.',
            budget: data['budget'] ?? 0,
            rating: (data['rating'] ?? 4.0).toDouble(),
            season: data['season'] ?? 'Toute l\'année',
            language: data['language'] ?? 'Local',
            currency: data['currency'] ?? 'EUR',
            temp: data['temp'] ?? '25°C',
            highlights: List<String>.from(data['highlights'] ?? []),
          );
        }).toList();
      }

      // 3. Si Firestore est vide, on retourne les destinations statiques de secours
      return _getStaticDestinations();
      
    } catch (e) {
      print("Erreur Firestore, chargement des destinations statiques : $e");
      // 4. En cas d'erreur, on retourne aussi la liste statique
      return _getStaticDestinations();
    }
  }

  // --- TA LISTE STATIQUE DE SECOURS (inchangée) ---
  List<Destination> _getStaticDestinations() {
    return [
      // ---------- AFRIQUE ----------
      Destination(
        id: '1', name: 'Djerba', country: 'Tunisie', flag: '🇹🇳',
        continent: 'Afrique', category: 'Plage',
        image: _img('photo-1507525428034-b723cf961d3e'),
        description: 'Île aux plages de sable fin, médinas colorées et douceur de vivre toute l\'année.',
        budget: 450, rating: 4.6,
        season: 'Mai – Octobre', language: 'Arabe, Français', currency: 'Dinar (TND)', temp: '28°C',
        highlights: ['Plage de Sidi Mahrez', 'Souk de Houmt Souk', 'Street art de Djerbahood'],
      ),
      Destination(
        id: '2', name: 'Marrakech', country: 'Maroc', flag: '🇲🇦',
        continent: 'Afrique', category: 'Culture',
        image: _img('photo-1597212618440-806262de4f6b'),
        description: 'La ville rouge : souks animés, palais et jardins au pied de l\'Atlas.',
        budget: 600, rating: 4.7,
        season: 'Mars – Mai', language: 'Arabe, Français', currency: 'Dirham (MAD)', temp: '24°C',
        highlights: ['Place Jemaa el-Fna', 'Jardin Majorelle', 'Souks de la médina'],
      ),
      Destination(
        id: '3', name: 'Le Caire', country: 'Égypte', flag: '🇪🇬',
        continent: 'Afrique', category: 'Culture',
        image: _img('photo-1539650116574-8efeb43e2750'),
        description: 'Entre pharaons et vie moderne, la porte d\'entrée des plus grands trésors antiques.',
        budget: 700, rating: 4.5,
        season: 'Octobre – Avril', language: 'Arabe', currency: 'Livre égyptienne (EGP)', temp: '27°C',
        highlights: ['Pyramides de Gizeh', 'Musée égyptien', 'Croisière sur le Nil'],
      ),
      Destination(
        id: '4', name: 'Le Cap', country: 'Afrique du Sud', flag: '🇿🇦',
        continent: 'Afrique', category: 'Nature',
        image: _img('photo-1580060839134-75a5edca2e99'),
        description: 'Montagnes, océans et vignobles : l\'un des plus beaux paysages du monde.',
        budget: 1300, rating: 4.8,
        season: 'Novembre – Mars', language: 'Anglais, Afrikaans', currency: 'Rand (ZAR)', temp: '22°C',
        highlights: ['Montagne de la Table', 'Cap de Bonne-Espérance', 'Route des vins'],
      ),

      // ---------- EUROPE ----------
      Destination(
        id: '5', name: 'Paris', country: 'France', flag: '🇫🇷',
        continent: 'Europe', category: 'Ville',
        image: _img('photo-1502602898657-3e91760cbb34'),
        description: 'Tour Eiffel, musées, cafés et architecture : la ville lumière.',
        budget: 900, rating: 4.7,
        season: 'Avril – Juin', language: 'Français', currency: 'Euro (€)', temp: '16°C',
        highlights: ['Tour Eiffel', 'Musée du Louvre', 'Croisière sur la Seine'],
      ),
      Destination(
        id: '6', name: 'Rome', country: 'Italie', flag: '🇮🇹',
        continent: 'Europe', category: 'Culture',
        image: _img('photo-1552832230-c0197dd311b5'),
        description: 'L\'histoire à chaque coin de rue, entre ruines antiques et cuisine italienne.',
        budget: 800, rating: 4.8,
        season: 'Avril – Mai', language: 'Italien', currency: 'Euro (€)', temp: '20°C',
        highlights: ['Colisée', 'Vatican', 'Fontaine de Trevi'],
      ),
      Destination(
        id: '7', name: 'Santorin', country: 'Grèce', flag: '🇬🇷',
        continent: 'Europe', category: 'Plage',
        image: _img('photo-1570077188670-e3a8d69ac5ff'),
        description: 'Villages blancs aux dômes bleus, perchés au-dessus de la mer Égée.',
        budget: 1100, rating: 4.9,
        season: 'Mai – Octobre', language: 'Grec', currency: 'Euro (€)', temp: '26°C',
        highlights: ['Coucher de soleil à Oia', 'Plage rouge', 'Dégustation de vins'],
      ),

      // ---------- ASIE ----------
      Destination(
        id: '8', name: 'Tokyo', country: 'Japon', flag: '🇯🇵',
        continent: 'Asie', category: 'Ville',
        image: _img('photo-1540959733332-eab4deabeeaf'),
        description: 'Tradition et futurisme : temples, néons, gastronomie et technologie.',
        budget: 1500, rating: 4.8,
        season: 'Mars – Mai', language: 'Japonais', currency: 'Yen (JPY)', temp: '18°C',
        highlights: ['Temple Senso-ji', 'Carrefour de Shibuya', 'Quartier d\'Akihabara'],
      ),
      Destination(
        id: '9', name: 'Bali', country: 'Indonésie', flag: '🇮🇩',
        continent: 'Asie', category: 'Nature',
        image: _img('photo-1537996194471-e657df975ab4'),
        description: 'Rizières en terrasses, temples sacrés et plages paradisiaques.',
        budget: 1200, rating: 4.5,
        season: 'Avril – Octobre', language: 'Indonésien', currency: 'Roupie (IDR)', temp: '29°C',
        highlights: ['Rizières de Tegallalang', 'Temple d\'Uluwatu', 'Plages de Seminyak'],
      ),
      Destination(
        id: '10', name: 'Istanbul', country: 'Turquie', flag: '🇹🇷',
        continent: 'Asie', category: 'Culture',
        image: _img('photo-1524231757912-21f4fe3a7200'),
        description: 'Entre Europe et Asie : mosquées, bazars et détroit du Bosphore.',
        budget: 650, rating: 4.6,
        season: 'Avril – Mai', language: 'Turc', currency: 'Livre turque (TRY)', temp: '18°C',
        highlights: ['Sainte-Sophie', 'Grand Bazar', 'Croisière sur le Bosphore'],
      ),
      Destination(
        id: '11', name: 'Maldives', country: 'Océan Indien', flag: '🇲🇻',
        continent: 'Asie', category: 'Plage',
        image: _img('photo-1514282401047-d79a71a590e8'),
        description: 'Eaux turquoise, sable blanc et bungalows sur pilotis.',
        budget: 2200, rating: 4.9,
        season: 'Novembre – Avril', language: 'Divehi, Anglais', currency: 'Rufiyaa (MVR)', temp: '30°C',
        highlights: ['Bungalows sur pilotis', 'Snorkeling avec raies manta', 'Îles de sable blanc'],
      ),

      // ---------- AMÉRIQUE ----------
      Destination(
        id: '12', name: 'New York', country: 'États-Unis', flag: '🇺🇸',
        continent: 'Amérique', category: 'Ville',
        image: _img('photo-1496442226666-8d4d0e62e6e9'),
        description: 'La ville qui ne dort jamais : gratte-ciel, musées et énergie unique.',
        budget: 1600, rating: 4.7,
        season: 'Avril – Juin', language: 'Anglais', currency: 'Dollar (USD)', temp: '15°C',
        highlights: ['Statue de la Liberté', 'Central Park', 'Times Square'],
      ),
      Destination(
        id: '13', name: 'Rio de Janeiro', country: 'Brésil', flag: '🇧🇷',
        continent: 'Amérique', category: 'Plage',
        image: _img('photo-1483729558449-99ef09a8c325'),
        description: 'Plages mythiques, samba et vues spectaculaires entre mer et montagnes.',
        budget: 1100, rating: 4.6,
        season: 'Décembre – Mars', language: 'Portugais', currency: 'Réal (BRL)', temp: '27°C',
        highlights: ['Christ Rédempteur', 'Plage d\'Ipanema', 'Pain de Sucre'],
      ),
      Destination(
        id: '14', name: 'Machu Picchu', country: 'Pérou', flag: '🇵🇪',
        continent: 'Amérique', category: 'Nature',
        image: _img('photo-1526392060635-9d6019884377'),
        description: 'La cité inca perdue, nichée dans les nuages des Andes.',
        budget: 1400, rating: 4.9,
        season: 'Mai – Septembre', language: 'Espagnol, Quechua', currency: 'Sol (PEN)', temp: '15°C',
        highlights: ['Cité inca', 'Chemin de l\'Inca', 'Vallée sacrée'],
      ),
      Destination(
        id: '15', name: 'Banff', country: 'Canada', flag: '🇨🇦',
        continent: 'Amérique', category: 'Nature',
        image: _img('photo-1561134643-668f9057cce4'),
        description: 'Lacs émeraude, glaciers et montagnes des Rocheuses canadiennes.',
        budget: 1300, rating: 4.8,
        season: 'Juin – Septembre', language: 'Anglais, Français', currency: 'Dollar canadien (CAD)', temp: '12°C',
        highlights: ['Lac Louise', 'Lac Moraine', 'Route des Glaciers'],
      ),

      // ---------- OCÉANIE ----------
      Destination(
        id: '16', name: 'Sydney', country: 'Australie', flag: '🇦🇺',
        continent: 'Océanie', category: 'Ville',
        image: _img('photo-1506973035872-a4ec16b8e8d9'),
        description: 'Baie sublime, plages urbaines et architecture emblématique.',
        budget: 1700, rating: 4.7,
        season: 'Septembre – Novembre', language: 'Anglais', currency: 'Dollar australien (AUD)', temp: '22°C',
        highlights: ['Opéra de Sydney', 'Bondi Beach', 'Harbour Bridge'],
      ),
    ];
  }
}