# Use the official NGINX image as the base
FROM nginx:alpine

# Copy your custom index.html into the NGINX web root
COPY index.html /usr/share/nginx/html/

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start NGINX in the foreground
CMD ["nginx", "-g", "daemon off;"]
