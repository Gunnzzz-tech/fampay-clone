import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../models/home_model.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "fampay",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 4),
            Image.asset(
              'assets/logo.png',
              height: 29,
              width: 29,
            ),
          ],
        ),
      ),
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(const FetchHomeData(isRefresh: true));
                // Add a small artificial delay so RefreshIndicator doesn’t disappear instantly
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                key: ValueKey(state.isRefreshed), // force rebuild on refresh
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: state.homeModel.sections.length,
                itemBuilder: (context, sectionIndex) {
                  final section = state.homeModel.sections[sectionIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: section.hcGroups.map((group) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (group.designType == "HC9" || group.designType == "HC1")
                            _buildCard(
                              group.cards.first,
                              group.designType,
                              context,
                              groupCards: group.cards,
                              groupHeight: group.height?.toDouble(),
                              isRefreshed: state.isRefreshed,
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: group.cards.map(
                                    (card) => _buildCard(
                                  card,
                                  group.designType,
                                  context,
                                  isRefreshed: state.isRefreshed,
                                ),
                              ).toList(),
                            ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            );
          } else if (state is HomeError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ------------------ Build card ------------------
  Widget _buildCard(
      CardItem card,
      String designType,
      BuildContext context, {
        List<CardItem>? groupCards,
        double? groupHeight,
        bool isRefreshed = false,
      }) {
    switch (designType) {
      case "HC3":
        return _bigDisplayCard(card, context);
      case "HC6":
        return _smallCardWithArrow(card, context);
      case "HC5":
        return _streakCard(card);
      case "HC9":
        return _gradientRow(groupCards ?? [], groupHeight ?? 200);
      case "HC1":
        if (isRefreshed) {
          print('Using _smallDisplayCardRefreshed for ${card.title}');
          return _smallDisplayCardRefreshedGroup(groupCards ?? [card]);
        } else {
          print('Using _smallDisplayCard for ${card.title}');
          return _smallDisplayCard(card, isRefreshed: isRefreshed);
        }
      default:
        return const SizedBox.shrink();
    }
  }
  //HC3: Big Display Card
  Widget _bigDisplayCard(CardItem card, BuildContext context) {
    final bgImage = card.bgImage?.imageUrl;
    final aspectRatio = card.bgImage?.aspectRatio ?? 1.0; // 👈 get aspect ratio
    final CtaItem? cta = card.cta.isNotEmpty ? card.cta.first : null;
    final url = card.url;
    bool showActions = false;

    return StatefulBuilder(
      builder: (context, setLocalState) {
        return Stack(
          children: [
            // 🔹 Action buttons behind card
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _actionButton(
                      Icons.alarm,
                      "remind later",
                      Colors.orange,
                          () => _handleRemindLater(card.id, context),
                    ),
                    const SizedBox(height: 16),
                    _actionButton(
                      Icons.close,
                      "dismiss now",
                      Colors.orange,
                          () => _handleDismissNow(card.id, context),
                    ),
                  ],
                ),
              ),
            ),

            // 🔹 The main card with slide + aspect ratio
            AnimatedSlide(
              duration: const Duration(milliseconds: 280),
              offset: showActions ? const Offset(0.25, 0) : Offset.zero,
              child: GestureDetector(
                onTap: () {
                  if (url != null && url.isNotEmpty) {
                    _openUrl(url); // 👈 handle url redirection
                  }
                },
                onLongPress: () => setLocalState(() => showActions = !showActions),
                child: AspectRatio(
                  aspectRatio: aspectRatio, // 👈 apply aspect ratio from JSON
                  child: _cardContent(context, card, bgImage, cta),
                ),
              ),
            ),
          ],
        );
      },
    );
  }


// --- helpers ---

  Widget _cardContent(BuildContext context, CardItem card, String? bgImage, CtaItem? cta) {
    return Container(

      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
        image: bgImage != null
            ? DecorationImage(
          image: NetworkImage(bgImage),
          fit: BoxFit.cover,
          onError: (_, __) => debugPrint("Image load failed: $bgImage"),
        )
            : null,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),

        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.45 * 0.32),
            if (card.formattedTitle != null && card.formattedTitle!.entities.isNotEmpty) ...[
              for (final entity in card.formattedTitle!.entities) ...[
                Text(
                  entity.text ?? "",
                  style: GoogleFonts.roboto(
                    fontSize: (entity.fontSize ?? 16).toDouble(),
                    color: _hexToColor(entity.color ?? "#FFFFFF"),
                    fontWeight: entity.fontFamily?.contains("semi_bold") == true
                        ? FontWeight.bold
                        : FontWeight.w300,

                  ),
                ),
                if (entity == card.formattedTitle!.entities.first) ...[
                  const Text(
                    "with action",
                    style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ],

            const Spacer(),
            if (cta != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hexToColor(cta.bgColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => debugPrint("Open URL: ${card.url}"),
                child: Text("    ${cta.text}    ", style: const TextStyle(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.black)),
        ],
      ),
    );
  }

// --- actions ---

// Remind later: hide now (session), reappear next app start
  void _handleRemindLater(int cardId, BuildContext context) {
    context.read<HomeBloc>().add(RemoveCard(cardId, dismissForever: false));
  }

// Dismiss now: persist forever
  Future<void> _handleDismissNow(int cardId, BuildContext context) async {
    context.read<HomeBloc>().add(RemoveCard(cardId, dismissForever: true));
  }
  /// function to convert hex to Color
  Color _hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  Future<void> _openUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }


  Widget _smallCardWithArrow(CardItem card, BuildContext context) {
    final iconUrl = card.icon?.imageUrl;
    final bgColor = _hexToColor(card.bgColor ?? "#FFFFFF");

    // fallback sizes if null
    final cardHeight = (card.height ?? 60).toDouble();
    final iconSize = (card.iconSize ?? 24).toDouble();

    return GestureDetector(
      onTap: () {
        if (card.url != null && card.url!.isNotEmpty) {
          _openUrl(card.url!);
        }

      },
      child: Container(
        height: cardHeight, // height from JSON
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          color: bgColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center, // center vertically
              children: [
                Row(
                  children: [
                    // leading icon
                    iconUrl != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        iconUrl,
                        width: iconSize,
                        height: iconSize,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.image_not_supported, size: iconSize),
                      ),
                    )
                        : Icon(Icons.image, size: iconSize),
                    const SizedBox(width: 8),

                    // title text
                    card.formattedTitle != null &&
                        card.formattedTitle!.entities.isNotEmpty
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: card.formattedTitle!.entities.map((e) {
                        return Text(
                          e.text ?? "",
                          style: GoogleFonts.roboto(
                            fontSize: 16, // always fixed
                            color: _hexToColor(e.color ?? "#000000"),
                            fontWeight: (e.fontFamily?.toLowerCase().contains("semi_bold") ?? false)
                                ? FontWeight.w600
                                : FontWeight.normal,

                          ),
                        );

                      }).toList(),
                    )
                        : Text(
                      card.title ?? card.name ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),

                // trailing arrow
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }


// HC5: Streak Card (Dynamic Height)
  Widget _streakCard(CardItem card) {
    final bgImage = card.bgImage?.imageUrl;
    final aspectRatio = card.bgImage?.aspectRatio ?? 1.0; // fallback
    final formattedTitle = card.formattedTitle;

    // Print aspect ratio
    print("Card '${card.title}' aspect ratio: $aspectRatio");

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.orangeAccent,
            image: bgImage != null
                ? DecorationImage(
              image: NetworkImage(bgImage),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black.withOpacity(0.3),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                if (formattedTitle != null && formattedTitle.entities.isNotEmpty)
                  Align(
                    alignment: formattedTitle.align == "center"
                        ? Alignment.center
                        : Alignment.centerLeft,
                    child: Text(
                      (() {
                        // Start with formatted title or fallback
                        String displayText = card.formattedTitle?.text ?? card.title ?? card.name ?? "";

                        // Replace placeholder `{}` with your desired text
                        if (displayText.contains("{}")) {
                          displayText = displayText.replaceAll("{}", "     Monkey smart text");
                          // 👆 change "Monkey Business" to whatever dynamic value you want
                        }

                        return displayText;
                      })(),
                      textAlign: (card.formattedTitle?.align?.toLowerCase() == "center")
                          ? TextAlign.center
                          : TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,

                      ),
                    ),
                  )
                else
                  Text(
                    card.title ?? '🔥 Streak!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _gradientRow(List<CardItem> cards, double height) {
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 7.0),
        itemCount: cards.length,
        separatorBuilder: (_, __) => const SizedBox(width: 2),
        itemBuilder: (context, index) {
          final card = cards[index];
          final aspectRatio = card.bgImage?.aspectRatio ?? 1.0;
          final width = height * aspectRatio;

          return _gradientCard(
            card,
            width: width,
            height: height,
          );
        },
      ),
    );
  }




// HC9: Gradient Cards
  Widget _gradientCard(CardItem card, {double? width, double? height}) {
    final colors = card.bgGradient?.colors
        .map((hex) => Color(int.parse(hex.replaceFirst('#', '0xff'))))
        .toList() ??
        [Colors.blue, Colors.purple];

    final angle = (card.bgGradient?.angle ?? 0).toDouble();
    final radians = angle * (3.14159265359 / 180);

    return Container(
      width: width,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: colors,

          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
          transform: GradientRotation(radians),
        ),
        image: card.bgImage?.imageUrl != null
            ? DecorationImage(
          image: NetworkImage(card.bgImage!.imageUrl!),
          fit: BoxFit.cover,
        )
            : null,
      ),
    );
  }

  Widget _smallDisplayCardRefreshedGroup(List<CardItem> cards) {
    final String textForWhite = "Small card with arrow";
    final String textForSmall = "Small card";

    final CardItem? c0 = cards.isNotEmpty ? cards[0] : null;
    final CardItem? c1 = cards.length > 1 ? cards[1] : null;

    Future<void> _launchUrl(String url) async {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    }

    Widget buildCard({
      required Color background,
      required bool isWhiteCard,
      required String title,
      String? subtitle,
      String? imageUrl,
      bool showArrow = false,
      double width = 160,
      String? url,
    }) {
      return GestureDetector(
        onTap: () {
          if (url != null && url.isNotEmpty) {
            _launchUrl(url); // 👈 opens browser
          }
        },
        child: Container(
          width: width,
          margin: const EdgeInsets.all(6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          height: 64,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Row(
            children: [
              if (isWhiteCard)
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 20),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: imageUrl != null
                      ? Image.network(imageUrl,
                      height: 36, width: 36, fit: BoxFit.cover)
                      : Container(
                    height: 36,
                    width: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const Icon(Icons.person,
                        color: Colors.black87, size: 20),
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showArrow)
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.black),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row 1: one white wide + one yellow
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (c0 != null)
                buildCard(
                  background: Colors.white,
                  isWhiteCard: true,
                  title: textForWhite,
                  width: 250,
                  showArrow: true,
                  url: c1?.url, // 👈 open URL from card 1 JSON
                ),
              if (c1 != null)
                buildCard(
                  background: Color(int.parse(
                      c1.bgColor?.replaceFirst('#', '0xff') ?? '0xffFBAF03')),
                  isWhiteCard: false,
                  title: textForSmall,
                  imageUrl: c0?.icon?.imageUrl,
                  width: 180,
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              buildCard(
                background: Colors.white,
                isWhiteCard: true,
                title: "Small card",
                width: 180,
              ),
              buildCard(
                background: Color(int.parse(
                    c1?.bgColor?.replaceFirst('#', '0xff') ?? '0xffFBAF03')),
                isWhiteCard: false,
                title: textForSmall,
                imageUrl: c0?.icon?.imageUrl,
                width: 180,
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _smallDisplayCard(CardItem card, {bool isRefreshed = false}) {
    print('Building _smallDisplayCard for ${card.title}, isRefreshed: $isRefreshed');

    return Center(
      child: Container(
        width: 375, // or adjust dynamically
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Color(int.parse(
              card.bgColor?.replaceFirst('#', '0xff') ?? '0xffFBAF03')),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (card.icon?.imageUrl != null)
              Image.network(
                card.icon!.imageUrl!,
                height: 40,
                width: 40,
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Small display card",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  Text(
                    "Arya Stark",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
