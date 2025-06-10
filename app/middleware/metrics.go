package middleware

import (
	"time"

	"github.com/gin-gonic/gin"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
)

var (
	httpRequestsTotal = promauto.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"method", "endpoint", "status"},
	)

	httpRequestDuration = promauto.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "Duration of HTTP requests in seconds",
			Buckets: prometheus.DefBuckets,
		},
		[]string{"method", "endpoint"},
	)

	activeRequests = promauto.NewGauge(
		prometheus.GaugeOpts{
			Name: "http_requests_in_progress",
			Help: "Number of HTTP requests currently in progress",
		},
	)
)

// PrometheusMiddleware returns a middleware that collects metrics
func PrometheusMiddleware() gin.HandlerFunc {
	return func(c *gin.Context) {
		start := time.Now()
		path := c.FullPath()
		method := c.Request.Method

		activeRequests.Inc()
		defer activeRequests.Dec()

		c.Next()

		status := c.Writer.Status()
		duration := time.Since(start).Seconds()

		httpRequestsTotal.WithLabelValues(method, path, string(rune(status))).Inc()
		httpRequestDuration.WithLabelValues(method, path).Observe(duration)
	}
}
