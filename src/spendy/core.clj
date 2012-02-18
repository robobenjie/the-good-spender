			       ;hide and show tags:
					;logged-in
					;not-logged-in
					;main-panel-queue
					;main-panel-signup
					;main-panel-about

(ns spendy.core
  (:use [hiccup core page-helpers]
	spendy.modals
	spendy.pwprot
	(sandbar stateful-session))
  (:require [clj-json.core :as json])
  (:import  [redis.clients.jedis Jedis JedisPool]))


(def site-name "The Good Spender")
(def nav-pages ["Home" "About" "Contact" "Blog"])
(def nav-targets ["#" "#about" "mailto:bmholson@gmail.com" "http://robobenjie.posterous.com/"])

(defn layout [title & body]
  (html5
   [:head 
    [:title title]
    (include-css "/css/bootstrap.css")
    (include-css "/css/jquery-ui-1.8.17.custom.css")
    (include-css "/css/spendy_addons.css")
    (include-js "/scripts/jquery.js")
    (include-js "/scripts/utils.js")
    (include-js "/scripts/make_html.js")
    (include-js "/scripts/IO.js")
    (include-js "/scripts/setup.js")
    (include-js "/scripts/wait.js")
    (include-js "/scripts/jquery-ui-1.8.17.custom.min.js")
    (include-js "/scripts/modals.js")
    (include-js "/scripts/scripts.js")]
   [:body 
    body
    (make-modal "create-item-modal"
		"New Thing to Save For"
		make-item-content
		(buttons [["create-btn" "Create" true ""]["cancel-create" "Cancel" false "close-modal"]]))
    
    (make-modal "create-user-modal"
		"Create a New Account"
		make-user-content
		(buttons [["create-user-btn" "Register" true ""]]))
    
    (make-modal "add-money-modal"
		"Add Money"
		add-money-content
		(buttons [["add-money-btn" "Add" true ""]["cancel-add" "Cancel" false "close-modal"]]))
    
    (make-modal "subtract-money-modal"
		"Subtract Money"
		subtract-money-content
		(buttons [["subtract-money-btn" "Subtract" true ""]["cancel-subtract" "Cancel" false "close-modal"]]))
       
    (make-modal "save-your-work-modal"
		"Save Your Work?"
		save-your-work-content
		(buttons [["cancel-save" "Not Yet" false "close-modal"] ["save-btn" "Make Account" true ""]]))
 
    
    ]))

(defn make-topbar[currentPage]
  [:div.topbar
   [:div.fill
    [:div.container
     [:a {:class "brand" :href "#"} site-name]
     [:ul.nav
      (map (fn [name, target] [(if (= name currentPage) :li.active :li) [:a {:href target} name]]) nav-pages nav-targets)]
     [:form {:action "/login" :id "loginForm" :method "get" :class "pull-right"}
      [:input#username-box {:class "input-small not-logged-in" :type "email" :placeholder "username"}]
      " "
      [:input#password-box {:class "input-small not-logged-in" :type "password" :placeholder "password"}]
      " "
      [:button#sign-in {:class "btn not-logged-in", :type "submit"} "Sign in"]
      [:button#log-out-btn {:class "btn logged-in"} "Log Out"] ]]]])

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

(defn salt-pw
  "remove return a user-obj with the password removed and a salt field  added"
  [user-obj]
  (if (user-obj "password")
    (assoc (dissoc user-obj "password")
      "salt"
      (protect-password (user-obj "password")))))
(defn update-cash
  "returns a user-obj that has a time field set to now and adds cash based on the
last time it was saved and the current 'rate' field"
  [user-obj]
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


(defn respond-to-ajax[type received-obj]
  (println "type:" type "object:" received-obj)
  (let [username (received-obj "email")]
    (condp = type  
      "save-data" 
        (save-to-redis username (salt-pw (update-cash received-obj)))
      "get-data"
	(let [username (or username (session-get :username) nil)
	      password (or (received-obj "password") (session-get :password) "")]
             	 (if (not (nil? username))
            	     (let [stored-obj (get-from-redis username)]
		         (println "I think: " username password)
		         (session-put! :username username)
		         (session-put! :password password)
         	         (if (verify-password password (stored-obj "salt"))
	              	     (do
				(println "passwords match")
				(update-cash stored-obj))
	      		     (do
				(println "passwords don't match.")
				{:message "bad password"})))
	             (do (println "no session") "")))
       "log-out"
	  (do
		(session-delete-key! :username)
		(session-delete-key! :password))
      "poop")))



(defn index-page []
  (layout site-name
	  (make-topbar "Home")
	  (content-area 
	   "main-panel-queue"
	   "Your Queue" 
	   " all the things you want to buy"
	   [:div
	    [:h2 "You have saved $"[:span#money-saved]]
	    [:div#queue-div]
	    [:a {:class "btn pad-left not-logged-in create-account-btn" :style "float: left"} [:span "Create Account"]]
	    [:a {:class "btn pad-right" :id "new-item" :style "float: right"} [:h3 "+"]]]
	   
	   (side-bar))
	  (content-area 
	   "main-panel-about"
	   "The Good Spender" 
	   " live well below your means"
	   [:div {:class "pad-left pad-right"}
	    [:h3 "Buy the things you want"]
	    [:p "Just tell us all the big ticket items you are excited to own. Then you pick how much you can afford to spend each month. We'll tell you when to buy each thing. You can afford to buy anything, you just need to wait longer for some things."]
	    [:hr]
	    [:h3 "Never go over budget"]
	    [:p "You pick how much you are going to spend each month. All we help you do is spread out your big purchases over time so you don't accidentally overspend."]
	    [:hr]
	    [:h3 "Use your money to be happier"]
	    [:p "Research shows that money can be used to buy happiness, but you only if you use it effectively. As soon as you buy something you quickly become accustomed to it and it gives you less and less joy. The Good Spender helps stretch out the anticipation so you get maximum happiness from your stuff. Because really, isn't that what buying things is all about?" ]
	    [:a {:href "http://dunn.psych.ubc.ca/files/2011/04/Journal-of-consumer-psychology.pdf"} "(Academic research on how to buy happiness)"]
	    [:hr]
	    [:a {:class "btn pad-left not-logged-in create-account-btn" :style "float: left"} [:span "Create Account"]]
	    [:a {:class "btn primary pad-right" :id "try-now-btn" :style "float: right"} "Try it out!"]]
	   
	   [:p "The Good Spender is created and maintained as a hobby by Benjie Holson. If you like it, hate it, or just want to chat shoot him an "[:a {:href "mailto:bmholson@gmail.com"} "email"]])
	  (content-area
	   "main-panel-sign-up"
	   "Sign Up!"
	   " it's fast and easy"
	   [:div
	    make-user-content
	    [:div#sign-up-errors]
	    [:a {:class "btn pad-left not-logged-in" :id "cancel-account-create-btn" :style "float: left"} [:span "Cancel"]]
	    [:a {:class "btn primary pad-right" :id "sign-up-btn" :style "float: right"} "Sign up"]]
	   [:span#sign-up-tips "I promise it will just take a moment and I'll walk you through it."])))
