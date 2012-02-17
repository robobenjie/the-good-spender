(defproject spendy "1.0.0-SNAPSHOT"
  :description "Spendy Website"
  :dependencies [[org.clojure/clojure "1.2.0"]
                 [org.clojure/clojure-contrib "1.2.0"]
                 [compojure "0.6.4"]
		 [hiccup "0.3.6"]
	         [sandbar/sandbar "0.4.0-SNAPSHOT"]
	         [ring-json-params "0.1.0"]
	         [clj-json "0.2.0"]
		 [redis.clients/jedis "1.5.2"]]
  :dev-dependencies [[lein-ring "0.4.5"]]
  :ring {:handler spendy.routes/app})
