# Prep Portage and Install

```bash
cd /etc/
echo "dev-java/icedtea-bin nss" >> /etc/portage/package.use/java
git add /etc/portage/package.use/java
emerge -avt dev-java/icedtea-bin:8
```
