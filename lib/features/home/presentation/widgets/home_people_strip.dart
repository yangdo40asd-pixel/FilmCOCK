import 'package:flutter/material.dart';
import 'package:filmcock_app/shared/domain/models/person.dart';

class HomePeopleStrip extends StatelessWidget {
  final List<Person> persons;
  final ValueChanged<Person> onPersonTap;

  const HomePeopleStrip({
    super.key,
    required this.persons,
    required this.onPersonTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: persons.length,
        itemBuilder: (context, index) {
          final person = persons[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () => onPersonTap(person),
              child: SizedBox(
                width: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40.0,
                      backgroundImage: person.fullProfileUrl.isNotEmpty
                          ? NetworkImage(person.fullProfileUrl)
                          : null,
                      backgroundColor: Colors.grey[800],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      person.displayName,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF191919),
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
