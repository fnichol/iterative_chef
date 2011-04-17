# More info at https://github.com/guard/guard#readme

guard 'ego' do
  watch('Guardfile')
end

guard 'compass' do
end

guard 'shell' do
  watch(%r{iterations/**/.+\.(sh|rb)})  { %x{rake docs} }
end

guard 'livereload' do
end
