
dd <- read.csv("data/2011_dec_raw.csv")

# чтобы убрать factors сначала преобразуем в строки
dd$exp <- as.numeric(as.character(dd$Общий.опыт.работы))
dd[dd$Общий.опыт.работы == "10 и более лет",c("exp")] <- 10
dd[dd$Общий.опыт.работы == "меньше 3 месяцев",c("exp")] <- 0

# сокращаем "Днепропетровск" до "Днепр.", для графиков
dd$Город <- as.character(dd$Город)
dd[dd$Город == "Днепропетровск",c("Город")] <- "Днепр."
dd$Город <- factor(dd$Город)

dd$title <- substr(dd$Должность, 1, 20) # Укорачиваем для графиков
top_cities <- c("Киев", "Харьков", "Львов", "Днепр.", "other")
dd$loc <- sapply(dd$Город, function(city) { factor(if (city %in% top_cities) substr(city, 1, 9) else "other", levels=top_cities) })

# переводим все зарплаты в доллары
dd$salary <- dd$Средняя.зарплата.в.месяц

# пытаемся убрать ошибки пользователей с неправильной валютой
dd[dd$salary > 5000 & dd$Возраст<26,c("Валюта")] <- "h"
dd[dd$Средняя.зарплата.в.месяц <2500 & dd$Валюта == "h",c("Валюта")] <- "d"

# dd[dd$salary > 4000,c("Валюта", "salary", "exp", "loc", "title")]
dd$salary[dd$Валюта == "h"] <- dd$Средняя.зарплата.в.месяц[dd$Валюта == "h"] / 8.0
# убираем подозрительные анкеты с зарплатами меньше $150 
dd <- dd[!dd$salary<150,]

pm_titles = c("Team lead", "Project manager", 
	"Senior Project Manager / Program Manager", 	
	"Director of Engineering / Program Director")
dev_titles = c("Junior Software Engineer", "Software Engineer",
	"Senior Software Engineer", "Technical Lead", "System Architect")
qa_titles = c("Junior QA engineer", "QA engineer",
	"Senior QA engineer", "QA Tech Lead")
other_titles = c("DBA / Администратор баз данных",
"Верстальщик", "Гейм-дизайнер", "Дизайнер",
"Системный администратор", "Технический писатель")


# классификация дерева должностей по группам
dd$cls <- ""
dd[dd$Должность %in% pm_titles, c("cls")] <- "PM"
dd[dd$Должность %in% dev_titles, c("cls")] <- "DEV"
dd[dd$Должность %in% qa_titles, c("cls")] <- "QA"
dd$cls <- factor(dd$cls)

dd$Возраст[dd$Возраст<15] <- NA
dd$Возраст[dd$Возраст>65] <- NA

write.table(dd,file="~/Projects/dou-salaries/data/2011_dec_final", sep=",")