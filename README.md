# yazdanhaider_Dynamic-App

assignment yazdan haider 21bce10015
<div align="center">
<img src="https://readme-typing-svg.herokuapp.com?color=9370DB&size=50&width=850&height=80&lines=Assignment-Neura-Dynamics"/>
</div>

![1](https://github.com/user-attachments/assets/fd89963f-c301-4068-89c8-0e47bc9ed14b)
# Homepage
![2](https://github.com/user-attachments/assets/a514bb5b-e417-4fa8-a33f-51ba9940d3f1)
# Multiple Themes
![4](https://github.com/user-attachments/assets/5633f8a7-64c1-4732-8a99-db9d51f96f5f)
# Checkout Process
![3](https://github.com/user-attachments/assets/d593c7aa-bbd2-4dd4-8f72-b8f2892e3eeb)


### Installation

1. **Clone the Repository:**

    ```bash
    git clone https://github.com/yazdanhaider/dynamics_project/
    ```

2. **Install Dependencies:**

    ```bash
    flutter pub get
    ```

3. **Run the App:**

    ```bash
    flutter run
    ```
## Code Structure

- `lib/`: Contains the main codebase.
  - `controllers/`: Business logic, state management
  - `data/`: Data models, API services, repositories
  - `themes/`: App themes, colors, styles
  - `ui/`: Reusable widgets, common UI components
  - `screens/`: App screens/pages
  - `main.dart`: Entry point of the application.

## Dependencies

- `flutter`: The Flutter SDK.
- `State Management`: provider, get.
- `UI`: google_fonts, flutter_svg, cached_network_image.
- `Network`: http, dio.
- `Storage`: shared_preferences, sqflite
- `Utils`: intl, url_launcher, image_picker.

## Requirements Fulfillment

This project was developed as part of a college assignment with specific requirements. Here's how each requirement was implemented:

### 1. API Integration
✅ Successfully integrated with `https://api.escuelajs.co/api/v1/products`
- Implemented in `product_provider.dart`
- Uses HTTP package for API calls
- Handles pagination and data fetching
- Includes retry mechanism for failed requests

### 2. Model Conversion
✅ Robust model implementation for API data
- Created `product_model.dart` with proper data typing
- Implemented JSON serialization/deserialization
- Added null safety throughout models
- Handles malformed URLs and data cleaning
- Smart image URL validation and fallback system

### 3. State Management
✅ Efficient state management using Provider
- `ProductProvider`: Manages product data, filtering, and sorting
- `CartProvider`: Handles shopping cart operations
- `ThemeProvider`: Controls app-wide theme settings
- Implements proper state lifecycles
- Optimized rebuilds for better performance

### 4. Error Handling
✅ Comprehensive error management
- Network error handling
- Image loading fallbacks
- Empty state handling
- User-friendly error messages
- Graceful degradation for missing data
- Loading states with shimmer effects

### 5. Clean Architecture
✅ Followed clean architecture principles:

**UI Layer** (`lib/ui/`)
- Separate screens for different features
- Reusable widgets
- Responsive layouts
- Platform-specific optimizations

**Controllers** (`lib/controllers/`)
- Business logic separation
- State management
- Data transformation
- Event handling

**Models** (`lib/data/models/`)
- Data structures
- Type definitions
- Validation logic
- Conversion methods

**Data Layer**
- API integration
- Data persistence
- Caching mechanisms
- Error handling

### 6. User Interface
✅ Modern and intuitive UI implementation
- Dark theme support
- Responsive grid layout
- Smooth animations
- Category filtering
- Search functionality
- Shopping cart interface
- Product details view
- Cross-platform compatibility

### Additional Achievements
- Implemented automated builds and releases
- Added cross-platform support (Android, Windows, Web, IOS)
- Optimized performance with caching
- Created responsive layouts for all screen sizes
- Added smart image loading system

---

Created with 💙 by Yazdan Haider
