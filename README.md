WD3: War Diary Data Digger
==========================

WD3 is a Rails app to process and view data from the Zooniverse project 'Operation War Diary' (OWD). You need MongoDB, Rails (3.2.5), and Ruby (1.9.3) to run this app. 

Get Going:
----------
- Initialise the database using Rails or simply import the most recent, empty version included in the project root as wd3-dd-mm-yyyy.sql.gz (if you're lazy like me).
- Adjust database.yml as needed and ensure that you have a recent Mongo dump of the OWD database.
- Check Rails app loads
- Import Subjects with `rails runner script/import_subjects.rb`
- Import classifications `rails runner script/import_subjects.rb`

Examples:
--------

These are all Rails console commands for now.

- `p = Page.find(<zooniverse_id>)`
- `p.activities` lists all activities tagge don page
- `p.date_means` shows all dates tagged on page with average y-axis positions