(ns spendy.amazon
  (:use am.ik.clj-aws-ecs)
  (:require [clj-json.core :as json]))
;(def requester (make-requester "ecs.amazonaws.com" "YOUR-ACCESS-KEY-ID" "YOUR-ACCESS-SECRET-KEY"))

(def amazon-key "AKIAJL4X7MAEWYX32VKQ")
(def amazon-secret-key "3Gcti+fq91776FwDpLvk4QvZSiA6i7MSUaosIx3S")
(def amazon-associates-id "thegoospe07-20")
(def requester (make-requester "ecs.amazonaws.com" amazon-key amazon-secret-key))
(defn get-raw 
      "searches amazon for an item"
      [title]
      (item-search-map requester "All" title {"ResponseGroup" "Images" "AssociateTag" "thegoospe07-20"}))
(defn is-tag? [tag]
      #(= tag (% :tag)))
(defn get-content [content tag]
      ((first (filter (is-tag? tag) content)) :content))
(defn get-info 
      "takes an Item from advertizing api and gives an object with just what I want"
      [Item]
      (let [content (Item :content)
	    ASIN (first (get-content content :ASIN))
	    SmallImageUrl (first (get-content (get-content content :SmallImage) :URL))]
	    {:ASIN ASIN :SmallImageUrl SmallImageUrl}))

(defn get-item-list [response]
      (filter (is-tag? :Item) (get-content (response :content) :Items)))

(defn get-images-from-amazon 
      "uses API call to fetch images related to keywords, parses them out and returns a list of maps of just what we want"	
      [keywords]
      (map get-info (get-item-list (get-raw keywords))))