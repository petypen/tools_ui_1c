
#Область СобытияФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ЗапросHTTP = "GET";
	КодировкаТелаЗапроса = "Авто";

	Элементы.КодировкаТелаЗапроса.СписокВыбора.Добавить("Системная");
	Элементы.КодировкаТелаЗапроса.СписокВыбора.Добавить("ANSI");
	Элементы.КодировкаТелаЗапроса.СписокВыбора.Добавить("OEM");
	Элементы.КодировкаТелаЗапроса.СписокВыбора.Добавить("UTF8");
	Элементы.КодировкаТелаЗапроса.СписокВыбора.Добавить("UTF16");

КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура ИсторияЗапросовВыбор(Элемент, ВыбраннаяСтрока, Поле,
		СтандартнаяОбработка)
	ЗаполнитьДанныеТекущегоЗапросаПоИстории(ВыбраннаяСтрока);
КонецПроцедуры

&НаКлиенте
Процедура ИсторияЗапросовПриАктивизацииСтроки(Элемент)
	ТекДанные=Элементы.ИсторияЗапросов.ТекущиеДанные;
	Если ТекДанные=Неопределено Тогда
		Возврат;
	КонецЕсли;
	Элементы.ГруппаСтраницыЗапроса.ТекущаяСтраница = Элементы.ГруппаАнализЗапроса;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ВыполнитьЗапрос(Команда)
	ВыполнитьЗапросНаСервере();
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ЗаголовкиЗапросаИзСтроки(СтрокаЗаголовков) Экспорт
	ТекстовыйДокумент=Новый ТекстовыйДокумент;
	ТекстовыйДокумент.УстановитьТекст(СтрокаЗаголовков);
	
	Заголовки=Новый Соответствие;
	
	Для НомерСтроки=1 По ТекстовыйДокумент.КоличествоСтрок() Цикл
		ЗаголовокСтр=ТекстовыйДокумент.ПолучитьСтроку(НомерСтроки);
		
		Если Не ЗначениеЗаполнено(ЗаголовокСтр) Тогда
			Продолжить;
		КонецЕсли;
		
		МассивЗаголовка=СтрРазделить(ЗаголовокСтр,":");
		Если МассивЗаголовка.Количество()<>2 Тогда
			Продолжить;
		КонецЕсли;
		
		Заголовки.Вставить(МассивЗаголовка[0],МассивЗаголовка[1]);
		
	КонецЦикла;
	
	Возврат Заголовки;
КонецФункции



&НаКлиенте
Процедура ЗаполнитьДанныеТекущегоЗапросаПоИстории(ВыбраннаяСтрока)
//Нужно установить текущую строку в параметры выполнения запроса
	ТекДанные = ИсторияЗапросов.НайтиПоИдентификатору(ВыбраннаяСтрока);

	Если ТекДанные = Неопределено Тогда
		Возврат;
	КонецЕсли;

	ЗапросHTTP = ТекДанные.HTTPФункция;
	URLЗапроса = ТекДанные.URL;
	ЗаголовкиСтрока = ТекДанные.ЗаголовкиЗапроса;
	ТелоЗапроса = ТекДанные.ТелоЗапроса;
	КодировкаТелаЗапроса = ТекДанные.КодировкаТелаЗапроса;
	ИспользоватьBOM = ТекДанные.BOM;

	Элементы.ГруппаСтраницыЗапроса.ТекущаяСтраница = Элементы.ГруппаЗапрос;
КонецПроцедуры

&НаСервере
Функция ПодготовленноеСоединение(СтруктураURL)
	Порт = Неопределено;
	Если ЗначениеЗаполнено(СтруктураURL.Порт) Тогда
		Порт = СтруктураURL.Порт;
	КонецЕсли;
	Если НРег(СтруктураURL.Схема) = "https" Тогда
		СоединениеHTTP = Новый HTTPСоединение(СтруктураURL.Сервер, Порт, , , , 30, Новый ЗащищенноеСоединениеOpenSSL);
	Иначе
		СоединениеHTTP = Новый HTTPСоединение(СтруктураURL.Сервер, Порт, , , , 30);
	КонецЕсли;

	Возврат СоединениеHTTP;
КонецФункции

&НаСервере
Функция ПодготовленныйЗапросHTTP(СтруктураURL)
	НовыйЗапрос = Новый HTTPЗапрос;

	СтрокаЗапроса = СтруктураURL.Путь;

	СтрокаПараметров = "";
	Для Каждого КлючЗначение ИЗ СтруктураURL.ПараметрыЗапроса Цикл
		СтрокаПараметров = СтрокаПараметров
			+ ?(ЗначениеЗаполнено(СтрокаПараметров), "?", "&") + КлючЗначение.Ключ + "="
			+ КлючЗначение.Значение;
	КонецЦикла;

	НовыйЗапрос.АдресРесурса = СтрокаЗапроса + СтрокаПараметров;

	Если ЗначениеЗаполнено(ТелоЗапроса) Тогда
		Если КодировкаТелаЗапроса = "Авто" Тогда
			НовыйЗапрос.УстановитьТелоИзСтроки(ТелоЗапроса);
		Иначе
			Если ИспользоватьBOM = 0 Тогда
				БОМ = ИспользованиеByteOrderMark.Авто;
			ИначеЕсли (ИспользоватьBOM = 1) Тогда
				БОМ = ИспользованиеByteOrderMark.Использовать;
			Иначе
				БОМ = ИспользованиеByteOrderMark.НеИспользовать;
			КонецЕсли;

			НовыйЗапрос.УстановитьТелоИзСтроки(ТелоЗапроса, КодировкаТелаЗапроса, БОМ);
		КонецЕсли;
	КонецЕсли;
	
	//Теперь нужно установить заголовки запроса
	НовыйЗапрос.Заголовки=ЗаголовкиЗапросаИзСтроки(ЗаголовкиСтрока);

	Возврат НовыйЗапрос;
КонецФункции

&НаСервере
Процедура ВыполнитьЗапросНаСервере()
	СтруктураURL = УИ_КоннекторHTTP.РазобратьURL(URLЗапроса);

	СоединениеHTTP = ПодготовленноеСоединение(СтруктураURL);

	НачалоВыполнения = ТекущаяУниверсальнаяДатаВМиллисекундах();
	Запрос = ПодготовленныйЗапросHTTP(СтруктураURL);
	ДатаНачала = ТекущаяДата();
	Попытка
		Если ЗапросHTTP = "GET" Тогда
			Ответ = СоединениеHTTP.Получить(Запрос);
		КонецЕсли;
	Исключение

	КонецПопытки;

	ОкончаниеВыполнения = ТекущаяУниверсальнаяДатаВМиллисекундах();

	ДлительностьВМилисекундах = ОкончаниеВыполнения - НачалоВыполнения;

	ЗафиксироватьЛогЗапроса(СтруктураURL.Сервер, СтруктураURL.Схема, Запрос, Ответ, ДатаНачала, ДлительностьВМилисекундах);

КонецПроцедуры

&НаСервере
Процедура ЗафиксироватьЛогЗапроса(АдресСервера, Протокол, HTTPЗапрос,
		HTTPОтвет, ДатаНачала, Длительность)

		//	Если HTTPОтвет = Неопределено Тогда 
	//		Ошибка = Истина;
	//	Иначе 
	//		Ошибка=Не ПроверитьУспешностьВыполненияЗапроса(HTTPОтвет);//.КодСостояния<>КодУспешногоЗапроса;
	//	КонецЕсли;
	ЗаписьЛога = ИсторияЗапросов.Добавить();
	ЗаписьЛога.HTTPФункция = ЗапросHTTP;
	ЗаписьЛога.АдресСервера = АдресСервера;
	ЗаписьЛога.Дата = ДатаНачала;
	ЗаписьЛога.ДлительностьВыполнения = Длительность;
	ЗаписьЛога.Запрос = HTTPЗапрос.АдресРесурса;
	ЗаписьЛога.ТелоЗапроса = HTTPЗапрос.ПолучитьТелоКакСтроку();
	ЗаписьЛога.КодСостояния = ?(HTTPОтвет = Неопределено, 500, HTTPОтвет.КодСостояния);
	ЗаписьЛога.Протокол = Протокол;
	//	ЗаписьЛога.Ошибка=Ошибка;
	ЗаписьЛога.ЗаголовкиЗапроса = ПолучитьСтрокуЗаголовков(HTTPЗапрос.Заголовки);
	ЗаписьЛога.ЗаголовкиОтвета = ?(HTTPОтвет = Неопределено, "", ПолучитьСтрокуЗаголовков(HTTPОтвет.Заголовки));
	ЗаписьЛога.ТелоОтвета = ?(HTTPОтвет = Неопределено, "См. журнал регистрации.", HTTPОтвет.ПолучитьТелоКакСтроку());
	ЗаписьЛога.URL = URLЗапроса;
	ЗаписьЛога.BOM = ИспользоватьBOM;
	ЗаписьЛога.КодировкаТелаЗапроса = КодировкаТелаЗапроса;
КонецПроцедуры

&НаСервере
Функция ПолучитьСтрокуЗаголовков(Заголовки)
	СтрокаЗаголовков = "";

	Для Каждого КлючЗначение Из Заголовки Цикл
		СтрокаЗаголовков = СтрокаЗаголовков
			+ ?(ЗначениеЗаполнено(СтрокаЗаголовков), Символы.ПС, "") + КлючЗначение.Ключ
			+ ":" + КлючЗначение.Значение;
	КонецЦикла;

	Возврат СтрокаЗаголовков;
КонецФункции

#КонецОбласти
