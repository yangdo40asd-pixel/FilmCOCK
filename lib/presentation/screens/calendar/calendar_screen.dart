import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:filmcock_app/data/models/movie_model.dart';
import 'package:filmcock_app/presentation/screens/calendar/calendar_add_movie_screen.dart';
import 'package:filmcock_app/presentation/screens/detail/movie_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late int _selectedYear;
  late int _selectedMonth;

  Map<String, List<Map<String, dynamic>>> _calendarData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _loadCalendarData();
  }

  Future<void> _loadCalendarData() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString('calendar_movies_data');
    final Map<String, List<Map<String, dynamic>>> parsed = {};

    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        decoded.forEach((dateKey, list) {
          if (list is List) {
            parsed[dateKey] = list
                .whereType<Map<String, dynamic>>()
                .map((m) => Map<String, dynamic>.from(m))
                .toList();
          }
        });
      } catch (_) {}
    }

    // Also link watched_movies_data to today if calendar is empty
    final now = DateTime.now();
    final todayKey =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (parsed.isEmpty) {
      final rawWatched = prefs.getStringList('watched_movies_data') ?? [];
      if (rawWatched.isNotEmpty) {
        final initialList = <Map<String, dynamic>>[];
        for (final item in rawWatched) {
          try {
            final m = jsonDecode(item) as Map<String, dynamic>;
            initialList.add({
              'id': m['id'],
              'title': m['title'],
              'posterPath': m['posterPath'],
              'addedAt': now.toIso8601String(),
            });
          } catch (_) {}
        }
        if (initialList.isNotEmpty) {
          parsed[todayKey] = initialList;
          await prefs.setString('calendar_movies_data', jsonEncode(parsed));
        }
      }
    }

    if (mounted) {
      setState(() {
        _calendarData = parsed;
        _isLoading = false;
      });
    }
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _getFirstWeekdayOffset(int year, int month) {
    // Sunday = 0, Monday = 1, ..., Saturday = 6
    final weekday = DateTime(year, month, 1).weekday;
    return weekday % 7;
  }

  void _showDayMoviesSheet(int day, List<Map<String, dynamic>> movies) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF222226),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📅 $_selectedYear년 $_selectedMonth월 $day일에 본 작품',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...movies.map((m) {
                final title = m['title'] as String? ?? '영화 제목';
                final posterPath = m['posterPath'] as String?;
                final movieId = int.tryParse(m['id'].toString()) ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E2E34),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: (posterPath != null && posterPath.isNotEmpty)
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w200$posterPath',
                                width: 44,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  width: 44,
                                  height: 60,
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.movie, color: Colors.white54),
                                ),
                              )
                            : Container(
                                width: 44,
                                height: 60,
                                color: Colors.grey[800],
                                child: const Icon(Icons.movie, color: Colors.white54),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          if (movieId > 0) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MovieDetailScreen(
                                  movie: Movie(
                                    id: movieId,
                                    title: title,
                                    overview: '',
                                    posterPath: posterPath,
                                    voteAverage: 8.0,
                                    releaseDate: '',
                                  ),
                                ),
                              ),
                            ).then((_) => _loadCalendarData());
                          }
                        },
                        child: const Text(
                          '상세보기',
                          style: TextStyle(color: Color(0xFFA88BFA)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF141414),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFA88BFA)),
        ),
      );
    }

    final now = DateTime.now();
    final daysInMonth = _getDaysInMonth(_selectedYear, _selectedMonth);
    final firstWeekdayOffset = _getFirstWeekdayOffset(_selectedYear, _selectedMonth);
    final totalCells = firstWeekdayOffset + daysInMonth;

    // Available years: past 2 years up to current year
    final availableYears = [now.year - 2, now.year - 1, now.year];
    if (!availableYears.contains(_selectedYear)) {
      availableYears.add(_selectedYear);
      availableYears.sort();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: _selectedYear,
            dropdownColor: const Color(0xFF222226),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            items: availableYears.map((y) {
              return DropdownMenuItem<int>(
                value: y,
                child: Text('$y년', style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedYear = val;
                  // If selected month in new year is in future, adjust to current month
                  if (_selectedYear == now.year && _selectedMonth > now.month) {
                    _selectedMonth = now.month;
                  }
                });
              }
            },
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Horizontal Month Chips (1월 ~ 12월)
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isSelected = month == _selectedMonth;
                final isFutureMonth = _selectedYear > now.year ||
                    (_selectedYear == now.year && month > now.month);

                return GestureDetector(
                  onTap: isFutureMonth
                      ? null
                      : () {
                          setState(() => _selectedMonth = month);
                        },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8.0, top: 6.0, bottom: 6.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: isFutureMonth
                          ? Colors.transparent
                          : (isSelected
                              ? const Color(0xFF282832)
                              : Colors.transparent),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: isFutureMonth
                            ? Colors.white10
                            : (isSelected ? Colors.white : Colors.white24),
                        width: 1.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$month월',
                      style: TextStyle(
                        color: isFutureMonth
                            ? Colors.white24
                            : (isSelected ? Colors.white : Colors.grey[500]),
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // 2. Main Calendar Card
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.all(18.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E24),
                  borderRadius: BorderRadius.circular(18.0),
                ),
                child: Column(
                  children: [
                    // Card Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '본 작품 캘린더',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$_selectedYear년 ${_selectedMonth.toString().padLeft(2, '0')}월',
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Calendar Days Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: totalCells,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        if (index < firstWeekdayOffset) {
                          return const SizedBox.shrink();
                        }

                        final day = index - firstWeekdayOffset + 1;
                        final isToday = _selectedYear == now.year &&
                            _selectedMonth == now.month &&
                            day == now.day;
                        final isFutureDay = _selectedYear > now.year ||
                            (_selectedYear == now.year && _selectedMonth > now.month) ||
                            (_selectedYear == now.year &&
                                _selectedMonth == now.month &&
                                day > now.day);

                        final dateKey =
                            '$_selectedYear-${_selectedMonth.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                        final movies = isFutureDay ? <Map<String, dynamic>>[] : (_calendarData[dateKey] ?? []);

                        return InkWell(
                          onTap: isFutureDay
                              ? null
                              : () {
                                  if (movies.isNotEmpty) {
                                    _showDayMoviesSheet(day, movies);
                                  }
                                },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            decoration: BoxDecoration(
                              color: (!isFutureDay && movies.isNotEmpty)
                                  ? const Color(0xFF26262E)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Day Number
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: isToday
                                        ? Border.all(
                                            color: const Color(0xFF8B5CF6),
                                            width: 2.2,
                                          )
                                        : null,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$day',
                                    style: TextStyle(
                                      color: isFutureDay
                                          ? Colors.white24
                                          : (isToday
                                              ? Colors.white
                                              : (day > 30 ? Colors.grey[700] : Colors.white70)),
                                      fontSize: 15,
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ),

                                // Watched Movie Posters (Wrapped)
                                if (!isFutureDay && movies.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Wrap(
                                    spacing: 2,
                                    runSpacing: 2,
                                    alignment: WrapAlignment.center,
                                    children: movies.map((m) {
                                      final posterPath = m['posterPath'] as String?;
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(3),
                                        child: (posterPath != null && posterPath.isNotEmpty)
                                            ? Image.network(
                                                'https://image.tmdb.org/t/p/w200$posterPath',
                                                width: 16,
                                                height: 22,
                                                fit: BoxFit.cover,
                                                errorBuilder: (c, e, s) => Container(
                                                  width: 16,
                                                  height: 22,
                                                  color: const Color(0xFF8B5CF6),
                                                  child: const Icon(
                                                    Icons.movie,
                                                    color: Colors.white,
                                                    size: 10,
                                                  ),
                                                ),
                                              )
                                            : Container(
                                                width: 16,
                                                height: 22,
                                                color: const Color(0xFF8B5CF6),
                                                child: const Icon(
                                                  Icons.movie,
                                                  color: Colors.white,
                                                  size: 10,
                                                ),
                                              ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Bottom Button: + 본 작품 추가하기
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4EE6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CalendarAddMovieScreen(),
                    ),
                  );
                  _loadCalendarData();
                },
                child: const Text(
                  '+  본 작품 추가하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
