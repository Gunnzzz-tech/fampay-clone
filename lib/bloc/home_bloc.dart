import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repository/home_repository.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../models/home_model.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeBloc(this.homeRepository) : super(HomeInitial()) {
    // Fetch data
    on<FetchHomeData>(_onFetchHomeData);

    // Refresh
    on<RefreshHome>((event, emit) async {
      add(const FetchHomeData(isRefresh: true));
    });

    // Remove card
    on<RemoveCard>(_onRemoveCard);
  }

  /// Handles fetching and filtering out dismissed cards
  Future<void> _onFetchHomeData(
      FetchHomeData event, Emitter<HomeState> emit) async {
    if (!event.isRefresh) emit(const HomeLoading());
    try {
      final homeData = await homeRepository.fetchHomeData();

      // Load dismissed card IDs from local storage
      final prefs = await SharedPreferences.getInstance();
      final dismissedIds =
          prefs.getStringList('dismissedCards')?.map(int.parse).toList() ?? [];

      // Filter cards recursively
      final filteredSections = homeData.sections.map((section) {
        final updatedGroups = section.hcGroups.map((group) {
          final updatedCards = group.cards
              .where((card) => !dismissedIds.contains(card.id))
              .toList();
          return group.copyWith(cards: updatedCards);
        }).toList();

        return section.copyWith(hcGroups: updatedGroups);
      }).toList();

      emit(HomeLoaded(
        homeModel: HomeModel(sections: filteredSections),
        isRefreshed: event.isRefresh,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }

  }
  Future<void> resetDismissedCards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('dismissedCards'); // ✅ match the key used above
  }


  /// Handles removing card from UI and persisting if needed
  Future<void> _onRemoveCard(RemoveCard event, Emitter<HomeState> emit) async {
    if (state is! HomeLoaded) return;

    final currentState = state as HomeLoaded;

    // Remove card from current state
    final updatedSections = currentState.homeModel.sections.map((section) {
      final updatedGroups = section.hcGroups.map((group) {
        final updatedCards =
        group.cards.where((c) => c.id != event.cardId).toList();
        return group.copyWith(cards: updatedCards);
      }).toList();

      return section.copyWith(hcGroups: updatedGroups);
    }).toList();

    // Persist if dismissForever
    if (event.dismissForever) {
      final prefs = await SharedPreferences.getInstance();
      final dismissedIds = prefs.getStringList('dismissedCards') ?? [];
      if (!dismissedIds.contains(event.cardId.toString())) {
        dismissedIds.add(event.cardId.toString());
        await prefs.setStringList('dismissedCards', dismissedIds);
      }
    }

    emit(currentState.copyWith(
      homeModel: HomeModel(sections: updatedSections),
    ));
  }
}
