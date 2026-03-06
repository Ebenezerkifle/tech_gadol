# Tech Gadol

A Flutter-based e-commerce application displaying product catalogs and details, featuring dynamic design and robust state management.

---

## Setup & Run Instructions

### Prerequisites
- **Flutter SDK:** The project relies on Flutter SDK `^3.10.3` (or any compatible Dart 3.x version).
- Ensure you have a working simulator (iOS/Android) or a connected device.

### Instructions
1. **Clone the repository** and navigate to the project directory:
   ```bash
   cd tech_gadol
   ```
2. **Install dependencies:**
   Fetch all required packages declared in `pubspec.yaml` (including Riverpod, GoRouter, Dio, and ScreenUtil):
   ```bash
   flutter pub get
   ```
3. **Generate code (Freezed & Hive):**
   The project uses `freezed` for explicit state union types and data models. It is critical to run `build_runner` to generate the `.freezed.dart` and `.g.dart` files:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
4. **Run the App:**
   ```bash
   flutter run
   ```

---

## Architecture Overview

The project follows a clean, feature-driven architectural structure aiming for high separation of concerns between logic, models, and UI components. 

### Folder Structure
```text
lib/
├── app/            # App-wide configurations like Routing (GoRouter) and responsive helpers
├── models/         # Core data structures (e.g., Product, ProductCategory)
└── providers/      # Dependency injection entries and global Riverpod provider instances
    └── Directory/    
        └── Provider # All the logics which are related to api calls are in here.
        └── State    # which stores us the state of the provider
        └── state.freezed
├── services/       # Network layers (Dio) connecting to the backend API (`product_api_service.dart`)
└── ui/
    ├── common/     # App-wide theme configs, colors, typography
    ├── views/      # Individual screens (e.g., ProductsView, ProductDetailView) separated logically
    └── widgets/    # Reusable standalone design components (ProductCard, CategoryChip)
```

### State Management Approach
The application utilizes **Riverpod** combined with **Freezed** for its state management implementation:
*   **Separation of Logic:** UI code simply watches providers (`ref.watch(productsViewProvider)`). The business logic (API calls, data transformation, pagination logic) entirely lives inside `StateNotifier` classes (e.g., `ProductsViewNotifier`).
*   **Explicit State Handling:** State representations use explicit Freezed Unions (`.initial()`, `.loading()`, `.loaded()`, `.empty()`, `.error()`). This enforces that distinct states map properly via Dart's `.when()` pattern matching, guaranteeing developers don't accidentally handle overlapping boolean phases.
*   **Testability:** API Services can be injected into notifiers, allowing unit tests to simulate and assert network events entirely without a graphical interface smoothly.

---

## Design System Rationale

The design logic is fundamentally centralized in `lib/ui/common/` (`app_colors.dart`, `app_text_style.dart`, `app_theme.dart`). 

*   **Responsiveness & Scaling:** The project relies on `flutter_screenutil` (utilizing `.w`, `.h`, `.r` extensions). Almost all hardcoded sizing scales dynamically, preventing clipped elements natively across mobile profiles and accommodating tablets correctly via fixed-width `masterList` strategies mapped in `ResponsiveHelper`.
*   **Component API Design:** Components like `CategoryChip` and `ProductCard` expose primitive logic (`isSelected`, `onTap`, `product`). They don't tightly couple to Riverpod inside themselves—instead, they remain "dumb" (pure) components, enforcing reusability.
*   **Theming:** The theme relies predominantly on standard Flutter `ThemeData` declarations mapped natively inside `main.dart`, which allows developers to swap light/dark palettes seamlessly without changing widget-level UI code. 

---

## Limitations & Improvements (With More Time)

If granted more time, several boundaries of the application could be enhanced:
1.  **Pagination Optimization & Debouncing:** The current "scroll-to-bottom" listener in `ProductsView` could be enhanced with better debouncing to prevent repetitive network triggers easily. Furthermore, the search bar lacks immediate debouncing currently.
3.  **Local Caching Policy:** Hive dependencies sit in the pubspec but are not utilized for caching. Implementing offline-first reads for `categories` and `products` would massively speed up startup times.
4.  **UI Layout Modularity:** In `products_view.dart`, checking `ResponsiveHelper.isTab()` controls rendering a Master-Detail format. Refactoring this into a more generic `AdaptiveLayoutWidget` would keep the Products screen code drastically shorter.
5.  **UI Improvment:** I would take some more time to make the UI intuative.
6.  **Write More Tests:** I couldn't get time to write all test cases.
7.  **Implement Dark Mode and Light Mode Feature:** I structured the project in a way to enable Theme toggling but I couldn't get time to finalize it.
---

## AI Tools Usage

During the course of developing and refining this project, AI tooling (specifically DeepMind agents) was utilized prominently for:
1.  **Scaffolding & Boilerplates:** Rapidly formatting Freezed states and drafting `StateNotifier` boilerplate structures.
2.  **To Generate Dart Models:** Creating a dart Models from such a large json file got a bit time consuming and so I used AI to help me generate Dart Models from an api response.
4.  **Help on Documentation:** I used an AI to help me organize this README documentation.