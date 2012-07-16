(ns spendy.routes
  (:use compojure.core
        spendy.core
	spendy.amazon
	ring.middleware.json-params
        [hiccup.middleware :only (wrap-base-url)]
	(sandbar stateful-session))
  (:require [compojure.route :as route]
            [compojure.handler :as handler]
            [compojure.response :as response]
	    [clj-json.core :as json]))



(defroutes main-routes
  (GET "/" [] (do (index-page)))
  (GET "/amazon" [] (map str (get-images-from-amazon "bunny")))
  (POST "/" [send_object]
	(let [obj (json/parse-string send_object) user (obj "object")]
			(json/generate-string (respond-to-ajax (obj "mtype") (obj "object")))))
  (route/resources "/")
  (route/not-found "404rd!"))

;(decorate main-routes (with-session :memory))

(def app
  (-> (handler/site main-routes)
      wrap-stateful-session
      (wrap-base-url)))