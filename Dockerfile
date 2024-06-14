# Use a imagem oficial do PHP para o ambiente de produção
FROM php:8.1-apache

# Atualiza o sistema e instala dependências necessárias
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && rm -rf /var/lib/apt/lists/*

# Instala extensões PHP necessárias
RUN docker-php-ext-install zip pdo_mysql

# Define o diretório de trabalho como /var/www/html
WORKDIR /var/www/html

# Copia os arquivos do projeto Laravel para o diretório de trabalho no container
COPY . .

# Instala as dependências do Composer sem pacotes de desenvolvimento
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Define as permissões necessárias para a aplicação Laravel
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Configura o DocumentRoot do Apache para apontar para a pasta 'public'
RUN sed -i -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/000-default.conf
RUN a2enmod rewrite

# Define a variável de ambiente para o DocumentRoot do Apache
ENV APACHE_DOCUMENT_ROOT /var/www/html/public

# Expõe a porta 8080 para o tráfego HTTP, conforme esperado pelo Cloud Run
EXPOSE 8080

# Comando padrão para iniciar o servidor Apache
CMD ["apache2-foreground"]