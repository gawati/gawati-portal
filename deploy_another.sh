#
# Creates a Second deployable package of gawati-portal
# Which can be deployed along side gawati portal
#
# CHANGE THESE
PACKAGE=gawati-another
USER=gawatianother
DESC="Gawati Another"
#
# DO NOT CHANGE THESE
# 
FOLDER=$PACKAGE
rm -rf ../$FOLDER
mkdir -p ../$FOLDER
cp -R * ../$FOLDER
cp -R *.* ../$FOLDER
cd ../$FOLDER
# repo.xml
sed -i 's|<target>gawatii-portal</target>|<target>'"$PACKAGE"'</target>|g' repo.xml
sed -i 's|<description>Gawati Portal</description>|<description>'"$DESC"'</description>|g' repo.xml
sed -i 's|user="gawatiportal"|user="'"$USER"'"|g' repo.xml
sed -i 's|group="gawatiportal"|group="'"$USER"'"|g' repo.xml
# build.xml
sed -i 's|value="gawati-portal"|value="'"$PACKAGE"'"|g' build.xml
sed -i 's|name="gawati-portal"|name="'"$PACKAGE"'"|g' build.xml
# expath-pkg.xml
sed -i 's|gawati-portal|'"$PACKAGE"'|g' expath-pkg.xml
sed -i 's|Gawati Portal|'"$DESC"'|g' expath-pkg.xml
sed -i 's|gawatiportal|'"$USER"'|g' _auth/_pw.xml
