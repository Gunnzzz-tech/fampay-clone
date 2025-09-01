import 'package:equatable/equatable.dart';
import '../models/home_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();

  @override
  String toString() => 'HomeInitial';
}

class HomeLoading extends HomeState {
  const HomeLoading();

  @override
  String toString() => 'HomeLoading';
}

class HomeLoaded extends HomeState {
  final HomeModel homeModel;
  final bool isRefreshed;

  const HomeLoaded({
    required this.homeModel,
    this.isRefreshed = false,
  });

  HomeLoaded copyWith({
    HomeModel? homeModel,
    bool? isRefreshed,
  }) {
    return HomeLoaded(
      homeModel: homeModel ?? this.homeModel,
      isRefreshed: isRefreshed ?? this.isRefreshed,
    );
  }

  @override
  List<Object> get props => [homeModel, isRefreshed];

  @override
  String toString() =>
      'HomeLoaded(isRefreshed: $isRefreshed, homeModel: $homeModel)';
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'HomeError(message: $message)';
}
