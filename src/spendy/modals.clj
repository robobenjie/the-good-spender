(ns spendy.modals
  (:use [hiccup core page-helpers]))

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
	 [:input {:class "large", :id "user-name-box", :name "name", :size 30, :type "text"}]]]
       [:div.clearfix
	[:label {:for "email"} "Email:"]
	[:div.input
	 [:input {:class "large", :id "user-email-box", :name "email", :size 30, :type "email"}]]]
       [:div.clearfix
	[:label {:for "password"} "Password:"]
	[:div.input
	 [:input {:class "large", :id "user-password-box", :name "password", :size 30, :type "password"}]]]
       [:div {:class "clearfix" :id "user-repeat-password-clearfix"}
	[:label {:for "password-repeat"} "Password Again:"]
	[:div.input
	 [:input {:class "large", :id "user-password-repeat-box", :name "password-repeat", :size 30, :type "password"}]
	 [:span.help-inline {:id "repeat-password-tip"} ""]]]]])

(def add-money-content
     [:div
      [:p "Maybe you got a check for your birthday, or maybe you just have money to burn. How much extra to you want to add in?"]
      [:div.clearfix
       [:label {:for "amount"} "How much money to add?"]
       [:div.input
	[:input {:class "large", :id "add-money-box", :name "amount", :size 30, :type "text"}]]]])

(def save-your-work-content
     [:div
      [:p "You have been at this a little while. Would you like to save your work?"]])

(def subtract-money-content
     [:div
      [:p "Spend some money? Dip into savings? Its ok: money is supposed to be spent. How much did you spend?"]
      [:div.clearfix
       [:label {:for "amount"} "How much money to remove?"]
       [:div.input
	[:input {:class "large", :id "subtract-money-box", :name "amount", :size 30, :type "text"}]]]])

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