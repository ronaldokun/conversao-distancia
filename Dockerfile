# Stage 1: Build dependencies
FROM python:3.12.8-slim-bookworm as builder

WORKDIR /app

# Install build dependencies
COPY requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /app/wheels -r requirements.txt

# Stage 2: Runtime
FROM python:3.12.8-slim-bookworm

WORKDIR /app

# Create non-root user
RUN useradd -m appuser && chown -R appuser:appuser /app
USER appuser

# Copy wheels from builder
COPY --from=builder /app/wheels /wheels
COPY --from=builder /app/requirements.txt .

# Install dependencies
RUN pip install --no-cache /wheels/*

# Copy application code
COPY . .

# Set environment variables
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
ENV PYTHONUNBUFFERED=1

# Expose port
EXPOSE 5000

# Add local bin to PATH
ENV PATH="/home/appuser/.local/bin:$PATH"

# Run application
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]