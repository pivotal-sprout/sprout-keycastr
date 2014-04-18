plist_filename = node['sprout']['keycastr']['plist_filename']

def construct(query)
  run_on_db = 'sqlite3 "/Library/Application Support/com.apple.TCC/TCC.db"'
  %Q(echo "#{query}" | #{run_on_db})
end

test_query = construct("SELECT allowed FROM access WHERE client = '#{plist_filename}';")
update_statement = construct("UPDATE access SET allowed = 1 WHERE client = '#{plist_filename}';")
insert_statement = construct("INSERT INTO access VALUES('kTCCServiceAccessibility','#{plist_filename}',0,1,1,NULL);")

test_cmd = Mixlib::ShellOut.new(test_query)
test_cmd.run_command

execute 'Update accessibility entry' do
  command update_statement
  only_if { test_cmd.stdout.strip != '' && test_cmd.stdout.strip != '1' }
end

execute 'Add accessibility entry' do
  command insert_statement
  only_if { test_cmd.stdout.strip == '' }
end
