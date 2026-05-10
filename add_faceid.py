import sys
path = 'Gestfina.xcodeproj/project.pbxproj'
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

if 'INFOPLIST_KEY_NSFaceIDUsageDescription' not in content:
    content = content.replace(
        'INFOPLIST_KEY_CFBundleDisplayName = GestFina;',
        'INFOPLIST_KEY_CFBundleDisplayName = GestFina;\n\t\t\t\tINFOPLIST_KEY_NSFaceIDUsageDescription = "Gestfina utilise Face ID pour protéger vos données";'
    )
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print('Added NSFaceIDUsageDescription to pbxproj')
else:
    print('Already present')
