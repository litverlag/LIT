# LIT
The Project for the LIT-Verlag
The Password for ALL test users is supposed to be password1

# Framework-Chain

	Ruby -> Rails -> ActiveAdmin

Thus we have the MVC design from rails, which active admin uses dynamically,
e.g. by saying:
'''
	controller do 
	  ...
	end
'''.

Unfortunately the ppl who started this projekt where like 'fsck MVC, we can do
better' and implemented some stuff violating the MVC concept. Most annoying
violation is
'''
	class SettingsProvider # Deprecated, finally!
	class InputSettings	   # Used in all .rhtml files, at least now dynamically
						   # gets types from the db, and entries from the entry
						   # names from the config/locales/*.yml file.
	class ShowSettings     # Same here.
'''.

# Usefull rake stuff.
 For more info check out the corresponding rake task information.
<script>
	rake notes
	rake db:save_settings
	rake db:load_settings
	rake db:stati
	rake db:accounts
	rake dbf:import
	rake gapi:import
	rake gapi:test
</script>

# Creating a new department.
 This is a journey. And I'm not talking about the nice kind of journey, where
 you learn some interesting stuff.
 A list of all places, that need change in case you need to add a department
 can be found here: <b>../add_new_department.madness</b>.

 vim: ft=markdown
