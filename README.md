Packer example to create images.

## Setup

### 1. Clone the repo
```bash
git clone https://github.com/n-traore/packer-examples.git && \
cd packer-examples
```

### 2. Run the config
Choose the system you want to build in the `src` folder, and run the config from the root folder. For example, to build a virtualbox VM with debian :
```bash
packer init src/virtualbox/debian/
packer validate src/virtualbox/debian/
packer build src/virtualbox/debian/
```
