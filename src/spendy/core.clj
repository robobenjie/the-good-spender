(ns spendy.core
  (:use [hiccup core page-helpers])
  (:require [clj-json.core :as json])
  (:import  [redis.clients.jedis Jedis JedisPool]))


(def site-name "The Good Spender")
(def nav-pages ["Home" "About" "Contact" "Blog"])
(def nav-targets ["#" "#about" "mailto:bmholson@gmail.com" "http://robobenjie.posterous.com/"])

(def make-item-content
  [:div
    [:div.clearfix
	[:label {:for "name"} "Item name?"]
	[:div.input
	    [:input {:class "large make-item-input", :id "name-box", :name "name", :size 30, :type "text"}]]]
    [:div.clearfix
	[:label {:for "price"} "Approximate cost?"]
	[:div.input
	    [:input {:class "large make-item-input", :id "price-box", :name "price", :size 30, :type "text"}]]]])

(def make-user-content
  [:div
	[:form
	    [:div.clearfix
		[:label {:for "name"} "Name:"]
		[:div.input
		    [:input {:class "large make-item-input", :id "user-name-box", :name "name", :size 30, :type "text"}]]]
	    [:div.clearfix
		[:label {:for "email"} "Email:"]
		[:div.input
		    [:input {:class "large make-item-input", :id "user-email-box", :name "email", :size 30, :type "text"}]]]
	    [:div.clearfix
		[:label {:for "password"} "Password:"]
		[:div.input
		    [:input {:class "large make-item-input", :id "user-password-box", :name "password", :size 30, :type "password"}]]]
	    [:div {:class "clearfix" :id "user-repeat-password-clearfix"}
		[:label {:for "password-repeat"} "Password Again:"]
		[:div.input
		    [:input {:class "large make-item-input", :id "user-password-repeat-box", :name "password-repeat", :size 30, :type "password"}]
		    [:span.help-inline {:id "repeat-password-tip"} ""]]]]])

(def add-money-content
    [:div
	[:p "Maybe you got a check for your birthday, or maybe you just have money to burn. How much extra to you want to add in?"]
	[:div.clearfix
	    [:label {:for "amount"} "How much money to add?"]
	    [:div.input
		[:input {:class "large make-item-input", :id "add-money-box", :name "amount", :size 30, :type "text"}]]]])
(def subtract-money-content
    [:div
	[:p "Spend some money? Dip into savings? Its ok: money is supposed to be spent. How much did you spend?"]
	[:div.clearfix
	    [:label {:for "amount"} "How much money to remove?"]
	    [:div.input
		[:input {:class "large make-item-input", :id "subtract-money-box", :name "amount", :size 30, :type "text"}]]]])

(defn buttons[data]
    (apply vector (cons :div (map #(vector :a {:class (str (if (% 2) "btn primary" "btn") " " (% 3)) :id (% 0)} (% 1)) data))))

(defn make-modal [id, headline, content, buttons]
    [:div.modal {:id id}
      [:form 
        [:div.modal-header
          [:a {:href "#", :class "close close-modal"} "x"]
          [:h3 headline]]
	[:div.modal-body content]
	[:div.modal-footer
	  buttons ]]])
*

(defn layout [title & body]
  (html5
    [:head 
    	   [:title title]
    	   (include-css "/css/bootstrap.css")
	   (include-css "/css/spendy_addons.css")
	   (include-js "/scripts/jquery.js")
	   (include-js "/scripts/make_html.js")
	   (include-js "/scripts/wait.js")
	   (include-js "/scripts/jquery-ui-1.8.16.custom.min.js")
	   (include-js "/scripts/scripts.js")]
    [:body 
    	   body
	   (make-modal "create-item-modal" "New Thing to Save For" make-item-content (buttons [["create-btn" "Create" true ""]["cancel-create" "Cancel" false "close-modal"]]))
	   (make-modal "create-user-modal" "Create a New Account" make-user-content (buttons [["create-user-btn" "Register" true ""]]))
	    (make-modal "add-money-modal" "Add Money" add-money-content (buttons [["add-money-btn" "Add" true ""]["cancel-add" "Cancel" false "close-modal"]]))
	    (make-modal "subtract-money-modal" "Subtract Money" subtract-money-content (buttons [["subtract-money-btn" "Subtract" true ""]["cancel-subtract" "Cancel" false "close-modal"]]))

]))

(defn make-topbar[currentPage]
      [:div.topbar
	[:div.fill
	  [:div.container
	    [:a {:class "brand" :href "#"} site-name]
	    [:ul.nav
		(map (fn [name, target] [(if (= name currentPage) :li.active :li) [:a {:href target} name]]) nav-pages nav-targets)]
	    [:form {:action "/login" :id "loginForm" :method "get" :class "pull-right"}
	     [:input#username-box {:class "input-small" :type "text" :placeholder "username"}]
	     " "
	     [:input#passowrd-box {:class "input-small" :type "password" :placeholder "password"}]
	     " "
	     [:button#sign-in {:class "btn", :type "submit"} "Sign in"]]]]])

(defn content-area [tag page-name tag-line main-content secondary-content]
    [:div {:class tag}
	[:div.container
	    [:div.content
		[:div.page-header
		    [:h1 page-name [:small tag-line]]]
		[:div.row
		    [:div.span10 main-content]
		    [:div.span4 secondary-content]]]]])
(defn side-bar []
    [:form
	[:fieldset
	    [:div.clearfix 
		[:label {:for "money-rate"} "Monthly Money: "]
		[:div.input
		    [:div.input-prepend
			[:span.add-on "$"]
			[:input {:class "span1_5" :id "money-rate" :name "money-rate" :type "text"}]]]]
	    [:div.clearfix
		[:label {:for "add-money"} "Add Money: "]
		[:div.input
		    [:a {:class "btn" :id "add-money" :name "add-money"} " + "]]]
	    [:div.clearfix
		[:label {:for "subtract-money"} "Remove Money: "]
		[:div.input
		    [:a {:class "btn" :id "subtract-money" :name "subtract-money"} " - "]]]]])


(defn get-from-redis[key]
     (let [*jedisPool* (JedisPool. "127.0.0.1" 6379)
           jedis (.getResource *jedisPool*)]
       (.select jedis 0)
       (let [value (json/parse-string  (.get jedis key))]
     	  (.returnResource *jedisPool* jedis)
	  value)))    


(defn save-to-redis[key value]
  (let [*jedisPool* (JedisPool. "127.0.0.1" 6379)
       jedis (.getResource *jedisPool*)
       value-string (json/generate-string value)]
    (.select jedis 0)

      (.set jedis key value-string)
      (.returnResource *jedisPool* jedis)
      "success"))

(defn update-cash [user-obj]
    (let [time (. System currentTimeMillis)]
	(if (user-obj "cash")
	    (if (user-obj "update-time")
		(assoc 
		    (assoc user-obj
			"update-time"
			time)
		    "cash"
		    (+ (user-obj "cash") (* 0.001 (user-obj "rate") (- time (user-obj "update-time")))))
		(assoc user-obj "update-time" time))
	    (assoc (assoc user-obj "update-time" time) "cash" 0))))



(defn respond-to-ajax[type recieved-obj]
      (println "type:" type "object:" recieved-obj)
      (let [username (recieved-obj "email")]
         (condp = type  
      	     "save-data" 
	     	(save-to-redis username (update-cash recieved-obj))
	     "get-data" 
	        (update-cash (get-from-redis username))
	     "poop")))



(defn index-page []
    (layout site-name
	(make-topbar "Home")
	(content-area 
	    "signed-in"
	    "Your Queue" 
	    " all the things you want to buy"
	    [:div
		[:h2 "You have saved $"[:span#money-saved]]
		[:div#queue-div]
		[:a {:class "btn pad-right" :id "new-item" :style "float: right"} [:h3 "+"]]]
	    (side-bar))
	(content-area
	    "sign-up"
	    "Sign Up!"
	    " it's fast and easy"
	    [:div
		make-user-content
		[:div#sign-up-errors]
		[:a{:class "btn primary pad-right" :id "sign-up-btn" :style "float: right"} "Sign up"]]
	    [:span#sign-up-tips "I promise it will just take a moment and I'll walk you through it."])))


