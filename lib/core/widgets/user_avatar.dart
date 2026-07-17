import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  final String name;
  final VoidCallback? onTap;
  final bool showCameraIcon;
  final String? heroTag;

  const UserAvatar({
    super.key,
    required this.photoUrl,
    required this.radius,
    required this.name,
    this.onTap,
    this.showCameraIcon = false,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallbackLetter = name.trim().isNotEmpty ? name.trim().substring(0, 1).toUpperCase() : 'U';

    Widget avatarChild;
    if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      avatarChild = CachedNetworkImage(
        imageUrl: photoUrl!,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: radius,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircleAvatar(
          radius: radius,
          backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: radius,
          backgroundColor: theme.colorScheme.error.withOpacity(0.12),
          child: Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: radius * 0.5),
        ),
      );
    } else {
      avatarChild = CircleAvatar(
        radius: radius,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
        child: Text(
          fallbackLetter,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: radius * 0.65,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    if (heroTag != null) {
      avatarChild = Hero(
        tag: heroTag!,
        child: avatarChild,
      );
    }

    if (onTap != null || showCameraIcon) {
      avatarChild = GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            avatarChild,
            if (showCameraIcon)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFF2563EB),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return avatarChild;
  }
}

class PhotoViewScreen extends StatelessWidget {
  final String photoUrl;
  final String name;
  final String heroTag;

  const PhotoViewScreen({
    super.key,
    required this.photoUrl,
    required this.name,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Hero(
            tag: heroTag,
            child: CachedNetworkImage(
              imageUrl: photoUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
              errorWidget: (context, url, error) => const Icon(Icons.error_outline_rounded, color: Colors.white, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}
