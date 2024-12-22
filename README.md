# Spinning Wheel App

This Flutter project implements a customizable spinning wheel feature, ideal for games, random selections, or decision-making tools. The project demonstrates advanced state management, weighted random selection, and responsive layouts.

## Features

- **Spinning Wheel**: A visually appealing wheel of fortune that selects items randomly.
- **Weighted Probability**: Items on the wheel can have weighted probabilities, allowing some options to appear more frequently than others.
- **Responsive Design**: Supports both portrait and landscape orientations.
- **Audio Integration**: Plays a dynamic spinning sound that slows down as the wheel stops.
- **Localizations**: Multi-language support for UI elements.
- **State Management**: Utilizes the Bloc pattern for clean and scalable architecture.

## Screenshots

Home - Settings - Item Details
[![Untitled-1.png](https://i.postimg.cc/J4FDsmGM/Untitled-1.png)](https://postimg.cc/Xpw7PRfz)

Edit an Item - Add an Item - Spin Result
[![Untitled-2.png](https://i.postimg.cc/Z5y93gd3/Untitled-2.png)](https://postimg.cc/5XbNWspN)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/MohammadBali/Spin_The_Wheel.git
   ```
2. Navigate to the project directory:
   ```bash
   cd spinning-wheel
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Usage

1. Add items to the spinning wheel through the `AppCubit` class.
2. Assign probabilities to each item in the list for weighted selection.
3. Press the **Spin** button to activate the wheel.
4. The result will be displayed via a snack bar message.

## Project Structure

- **`lib`**: Contains the main source code.
    - `layout/`: Defines the main layout and state management cubit.
    - `models/`: Holds the data model for items on the spinning wheel.
    - `modules/`: Contains feature-specific modules (e.g., Home, Items, Settings).
    - `shared/`: Includes shared components, styles, and utilities.

## Customization

- **Items**: Modify the `Items` list from `Settings.dart` to customize the labels and probabilities.
- **Audio**: Replace the spinning wheel sound file in `assets/sounds/` with your own sound.
- **Localization**: Update `languages.dart` to add or modify language strings.
- **Modes**: Light & Dark Mode themes.

## Dependencies

Key packages used in this project:
- [flutter_bloc](https://pub.dev/packages/flutter_bloc) for state management.
- [flutter_fortune_wheel](https://pub.dev/packages/flutter_fortune_wheel) for the spinning wheel component.
- [audioplayers](https://pub.dev/packages/audioplayers) for sound effects.



## By Mohammad Bali
