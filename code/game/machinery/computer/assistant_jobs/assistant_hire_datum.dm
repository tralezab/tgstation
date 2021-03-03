
#define CATEGORY_FRUITS_VEGGIES 1
#define CATEGORY_MILK_EGGS 2
#define CATEGORY_SAUCES_REAGENTS 3

///A datum for chef ordering options from the chef's computer.
/datum/assistant_hire





	var/title = "Orderable Item Name"
	//if not null, females will get this title.
	var/female_title
	//description set automatically unless it's hard set by the subtype
	var/general_desc
	var/payment_desc
	var/credit_payment = 10

/datum/assistant_hire/New()

/datum/assistant_hire/Destroy(force, ...)
	. = ..()
	qdel(item_instance)

/datum/assistant_hire/sampler
	title = "Sample Collector"
	general_desc = "As the Sample Collector, you will swab maintenance (and wherever else you can get samples) and return them to the xenobiologist."
	payment_desc = "Payment delivered for each sample returned."
	credit_payment = 40

/datum/assistant_hire/waiter
	title = "Waiter"
	female_title = "Waitress"
	general_desc = "As the Waiter/Waitress, you will deliver dishes and drinks to customers. Your presence attracts more customers."
	payment_desc = "A cut of every dish will be given to you as tips, the rest should be delivered to the chef. Chefs may choose to reward a job well done."
	credit_payment = 20

