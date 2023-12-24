part of 'post_item_bloc.dart';

@immutable
abstract class PostItemState {}

class PostItemInitial extends PostItemState {
}

class PostItemNormal extends PostItemState {
  PostItemUIData postData;

  PostItemNormal(this.postData);
}