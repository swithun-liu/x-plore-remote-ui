import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:x_plore_remote_ui/view/component/post/data/PostUIData.dart';

part 'post_item_event.dart';
part 'post_item_state.dart';

class PostItemBloc extends Bloc<PostItemEvent, PostItemState> {
  PostItemBloc(PostItemState initialSate) : super(initialSate) {
    on<PostItemEvent>((event, emit) {

    });
  }
}
