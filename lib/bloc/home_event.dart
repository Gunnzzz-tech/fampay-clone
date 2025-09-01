import 'package:equatable/equatable.dart';

/// Base class for all Home events
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch initial or refreshed data
class FetchHomeData extends HomeEvent {
  final bool isRefresh;

  const FetchHomeData({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

/// Refresh data (simply triggers [FetchHomeData] internally)
class RefreshHome extends HomeEvent {
  const RefreshHome();
}

/// Remove a card (with optional permanent dismissal)
class RemoveCard extends HomeEvent {
  final int cardId;
  final bool dismissForever;

  const RemoveCard(this.cardId, {this.dismissForever = false});

  @override
  List<Object?> get props => [cardId, dismissForever];
}