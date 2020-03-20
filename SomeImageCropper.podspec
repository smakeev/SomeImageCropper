Pod::Spec.new do |s|
  s.name = 'SomeImageCropper'
  s.version = '0.0.1'
  s.license = 'MIT'
  s.summary = 'Make selection on image and crop this selection'
  s.homepage = 'https://github.com/smakeev/SomeImageCropper'
  s.authors = { 'Sergey Makeev' => 'makeev.87@gmail.com' }
  s.source = { :git => 'https://github.com/smakeev/SomeImageCropper.git', :tag => s.version }
  s.documentation_url = 'https://github.com/smakeev/SomeImageCropper/wiki'
  s.dependency 'SomeInnerView'
  s.ios.deployment_target = '10.0'

  s.swift_versions = ['5.1']

  s.source_files = 'SomeImageCropper/SomeImageCropper/*.swift'
end
