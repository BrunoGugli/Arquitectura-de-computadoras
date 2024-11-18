## Cómo usar la interfaz gráfica

### Instalar poetry con pip o con apt

```bash
pip install poetry
```

```bash
sudo apt install poetry
```

### Instalar las dependencias del proyecto

Antes de esto se recomienda iniciar un entorno virtual propio de poetry:

Dirigirse a la carpeta UI y ejecutar:

```bash
poetry shell
```

Ahora sí, instalar las dependencias:

```bash
poetry install
```

### Ejecutar la interfaz gráfica

```bash
python3 serial_app.py <puerto> <baudrate>
```
