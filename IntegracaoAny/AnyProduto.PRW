#INCLUDE "PROTHEUS.CH"
#Include "aarray.ch"
#Include "json.ch"

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: AnyProduto
Tipo		: CLS = Classe
Descri��o	: Classe de produtos do Anymarket
Par�metros	: Nil
Retorno		: Nilean
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 16/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Class AnyProduto From AnyAcesso

	Data cCodigo 
	Data cIdWeb
	Data cIdSku

	Data cDesc
	Data nPeso
	Data nLargura
	Data nComprimento
	Data nAltura
	Data nTempGarantia
	Data cDesGarantia
	Data nMarkup
	Data nTipoPreco //= 1 = MANUAL 2 = AUTOM�TICO
	Data cInfomacoes
	Data cOrigem
	Data aSKUs
	Data aCaracte
	Data cModelo
	Data cNBM
	
	Data cIdCateg
	Data cDescCate
	Data cIdMarca
	Data cDescMarca
	Data aEstoques
	Data aPrecos
	Data aListaProd
	  	
	Method New() CONSTRUCTOR
	Method CriaProduto()
	Method AddSku()
	Method AddCaracte()
	Method GetProd()
	Method AtuaProduto()

	Method AllProdutos()
	Method AllAtuEstoques()
	Method AllAtuPreco()

EndClass             

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: AnyProduto
Tipo		: MTH = Metodo
Descri��o	: Construtor do Objeto
Par�metros	: Nil
Retorno		: Nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 16/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Method New() Class AnyProduto
	_Super:New()
	
	::cCodigo 		:= ""
	::cIdWeb		:= ""
	::cIdSku		:= ""
	
	::cDesc			:= ''
	::nPeso			:= 0
	::nLargura		:= 0
	::nComprimento	:= 0
	::nAltura		:= 0
	::nTempGarantia	:= 0
	::cDesGarantia	:= ''
	::nMarkup		:= ''
	::nTipoPreco 	:= 1 //= 1 = MANUAL 2 = AUTOM�TICO
	::cInfomacoes	:= ''
	::cOrigem		:= ''
	::aSKUs			:= {}
	::aCaracte		:= {}
	::cModelo		:= ''
	::cNBM			:= ''
	
	//Vari�veis de retorno
	::cIdCateg		:= ''
	::cDescCate		:= ''
	::cIdMarca		:= ''
	::cDescmarca	:= ''
	::aEstoques		:= {}
	::aPrecos		:= {}
	::aListaProd	:= {}
	
	//;;Self:AllProdutos()
	
Return Self

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: CriaProduto
Tipo		: MTH = Metodo
Descri��o	: Cria os produtos no AnyMarket
Par�metros	: Nil
Retorno		: Nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 16/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Method CriaProduto() Class AnyProduto	
	Local cRespJSON		:= ''
	Local cHeaderRet 	:= ''
	Local cUrl			:= ::cURLBase+'/products'
	Local cJSon			:= ''
	Local nPos			:= 0
	Local aMsgErro 		:= {}
	Local nI			:= 0
	Local lRet			:= .F.
	Local cJsonSku		:= ''

	Private oJsProduto:= Nil
	
	::cIdWeb := ''
	
	If AllTrim(::cCodigo) == ''
		Return
	EndIf

	cProduto := AllTrim(::cCodigo)
	//cProduto := TrataProd(cProduto)
	cRespJSON := HTTPGet(cUrl,,,::aHeadStr,@cHeaderRet)

	If cRespJSON <> NIL .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)

		cDescricao	:= Replace(::cDesc,"�","''")

		cJSon := '	{ '
		cJSon += MontaJson(Self)
		
		//Categoria
		If AllTrim(::cIdCateg) <> ''		
			cJSon += ',  	"category": '
			cJSon += '  		{'
			cJSon += '    		"id": "'+AllTrim(::cIdCateg)+'" '	//C�digo da categoria
			cJSon += '  		} '
		EndIf
		
		//Marca
		If Valtype(::cIdMarca) == 'C'
			::cIdMarca := Val(::cIdMarca)
		EndIf
		
		If Valtype(::cIdMarca) == 'N' .AND. ::cIdMarca <> 0
			cJSon += ',  	"brand": '
			cJSon += '  		{'
			cJSon += '    		"id": "'+cValToChar(::cIdMarca)+'" '	//C�digo da categoria
			cJSon += '  		} '			
		EndIf

		If Len(::aSkus) > 0
			For nI := 1 to Len(::aSkus)
				If !Empty(cJsonSku)
					cJsonSku += ','
				EndIf
				
				oSku := ::aSkus[nI]
				
				If ValType(oSku) <> 'O'
					Loop
				EndIf
				
				cJsonSku += ' {'
				
				If !Empty(oSku:cCodBarra)
					cJsonSku += '	 "ean": "'+AllTrim(oSku:cCodBarra)+'",'	//C�digo de barras
				EndIf
				
				cJsonSku += '	   	"canEditEan": true'				//Edita o c�digo de barras
				cJsonSku += '	, 	"partnerId": "'+AllTrim(oSku:cCodProd)+'"'	//ID do produto	
				cJsonSku += '	,	"amount": '+cValToChar(oSku:nQde) 				//Quantidade
				cJsonSku += '	,	"title": "'+AllTrim(oSku:cDesc)+'"'		//T�tulo SKU
				cPreco := StrTran( cValToChar( Round(oSku:nPreco,2)), ',', '.')
				cJsonSku += '	, 	"price": '+cPreco				//Pre�o de venda
								
				cJsonSku += ' }'					
			Next

			If Len(::aSkus) > 0
				cJSon += ',	"skus": ['	
				cJSon += cJsonSku
				cJSon += '] '
			EndIf

			cJSon += '}'

			cHeaderRet := '' 
			cRespJSON := HTTPPost(cUrl,,cJSon,,::aHeadStr,@cHeaderRet)
			
			//code":"500","message":"Duplicidade de SKU
			If ValType(cRespJSON) == 'C'
				If "200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet .AND. !('Duplicidade de SKU' $ cRespJSON)
					FWJsonDeserialize(cRespJSON,@oJsProduto)
					::cIdWeb 	:= cValToChar(oJsProduto:ID)
					::cIdCateg	:= '' 
					::cDescCate := ''
					::cIdMarca 	:= ''
					::cDescmarca:= ''
					
					If Type('oJsProduto:skus') <> 'U'
						For nI := 1 to Len(oJsProduto:skus)
							If Type('oJsProduto:skus['+cValToChar(nI)+']:ID') <> 'U'
								AddIDSku(Self, oJsProduto:skus[nI])
								//::cIdSku := cValToChar(oJsProduto:skus[nI]:ID)
							EndIf
						Next
					Endif
					
					If Type('oJsProduto:category:id') <> 'U'
						::cIdCateg := cValToChar(oJsProduto:category:ID)
						::cDescCate := AllTrim(oJsProduto:category:Name)
					EndIf
					
					If Type('oJsProduto:brand:id') <> 'U'
						::cIdMarca 	:= cValToChar(oJsProduto:brand:ID)
						::cDescmarca 	:= AllTrim(oJsProduto:brand:Name)
					EndIf
					
					//aAdd(::aListaProd, {::cIdWeb, ::cIdSku, cProduto, ::cIdCateg, ::cDescCate, ::cIdMarca, ::cDescmarca })
					lRet := .T.
				Else
					aMsgErro := {}
					aAdd(aMsgErro, 'Cadastro de produto')
					aAdd(aMsgErro, cUrl)
					aAdd(aMsgErro, cRespJSON)
					aAdd(aMsgErro, cJSon)
					Self:EmailErro(aMsgErro)
					lRet := .F.
				EndIf				
			EndIf
		EndIf
	EndIf	
Return lRet

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: AddSku
Tipo		: MTH = Metodo
Descri��o	: Adiciona o objeto Sku no objeto produto
Par�metros	: Nil
Retorno		: Nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 16/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Method AddSku(oSku) Class AnyProduto
	Local oObj 	:= AnySku():New()
	Default oSku := nil
	
	If ValType(oSku) == "O"
		oObj:cIdWeb		:= AllTrim(oSku:cIdWeb)
		oObj:cDesc 		:= AllTrim(oSku:cDesc)
		oObj:nPreco		:= oSku:nPreco
		oObj:cCodProd 	:= AllTrim(oSku:cCodProd)
		oObj:nQde		:= oSku:nQde
		oObj:cCodBarra 	:= AllTrim(oSku:cCodBarra)		

		aAdd(::aSkus, oObj)
	EndIf
Return

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: AddCaracte
Tipo		: MTH = Metodo
Descri��o	: Adiciona o objeto Sku no objeto produto
Par�metros	: Nil
Retorno		: oExp1 : Objto de caracteristicas
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 16/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Method AddCaracte(oCaracteri) Class AnyProduto
	Local oObj 	:= AnyCaracte():New()
	Default oCaracteri := nil
	
	If ValType(oCaracteri) == "O"
		oObj:cTitulo 	:= AllTrim(oCaracteri:cTitulo)
		oObj:cValor		:= AllTrim(oCaracteri:cValor)

		aAdd(::aCaracte, oObj)
	EndIf
Return


//============================================================================
Static Function MontaJson(oAnyProd)
	Local cJSon 		:= ''
	Local nGarantia 	:= 0
	Local cDescricao	:= ''
	Local cInformacoes	:= ''
	Local cOrigANY		:= ''
	Local cCaracteris	:= ''
	Local cTitulo		:= ''
	Local cJsonCarac	:= ''
	Local nI			:= 0

	cDescricao 	:= AllTrim(oAnyProd:cDesc)
	cDescricao	:= Replace(cDescricao,"�","''")
					
	cJSon += ' "priceFactor": '+cValToChar(oAnyProd:nMarkup) 	//Markup
	cJSon += ', "title": "'+cDescricao+'"'  			//Descri��o do produto
	
	If oAnyProd:nTipoPreco == 2
		cJSon += ', "calculatedPrice": false'
	Else
		cJSon += ', "calculatedPrice": true'//Pre�o manual
	EndIf
	
	If oAnyProd:cModelo != ""
		cJSon += ', "model": "'+AllTrim(oAnyProd:cModelo)+'"'
	EndIf
	
	If oAnyProd:nTempGarantia > 0
		cJSon += ', "warrantyTime": '+cValToChar(oAnyProd:nTempGarantia)
	EndIf
	
	If !Empty(oAnyProd:cDesGarantia)
  		cJSon += ', "warrantyText": "'+RetiraCaracEsp(oAnyProd:cDesGarantia)+'"'
  	EndIf
    
    If oAnyProd:nAltura > 0
	  	cJSon += ', "height": '+cValToChar(Ceiling(oAnyProd:nAltura))			//Altura
	EndIf
	
	If oAnyProd:nAltura > 0
	  	cJSon += ', "width": '+cValToChar(Ceiling(oAnyProd:nLargura)) 			//Largura
	EndIf
	
	If oAnyProd:nComprimento > 0  	
	  	cJSon += ', "length": '+cValToChar(Ceiling(oAnyProd:nComprimento))		//Comprimento
	EndIf
      	
    If !empty(oAnyProd:cInfomacoes)
	  	cInformacoes := AllTrim(oAnyProd:cInfomacoes)
	  	cInformacoes := RetiraCaracEsp(cInformacoes)
	  	cInformacoes := TrataDescr(cInformacoes)
	    cInformacoes := '</p>'+cInformacoes+'<p>'  
	      	
	    cJSon += ', "description": "'+ cInformacoes+'"' //Especifica��es t�cnicas
	EndIf
	
	For nI := 1 to Len(oAnyProd:aCaracte)
		If !Empty(cJsonCarac)
			cJsonCarac += ', '
		EndIf
		
		oCatacte := oAnyProd:aCaracte[nI]
		cCaracteris 	:= AllTrim(oCatacte:cValor) 
  		cCaracteris 	:= RetiraCaracEsp(cCaracteris)
  		//cCaracteris 	:= TrataDescr(cCaracteris)

		cTitulo 		:= AllTrim(oCatacte:cTitulo) 
  		cTitulo 		:= RetiraCaracEsp(cTitulo)
  		//cTitulo 		:= TrataDescr(cTitulo)			

		cJsonCarac += ' { '
		cJsonCarac += '	    "name": "'+AllTrim(cTitulo)+'" '
		cJsonCarac += ',    "value": "'+AllTrim(cCaracteris)+'" '
		cJsonCarac += ' } '
	Next
	
	cJSon += ', "characteristics": ['
	cJSon += cJsonCarac 
	cJSon += ']'
   
   	cJSon += ', "weight": '+cValToChar(Ceiling(oAnyProd:nPeso))//Peso
   	
   	If !Empty(oAnyProd:cOrigem) 
		cJSon += ', "origin": {'
	   	cJSon += ' 		"id": '+oAnyProd:cOrigem	
	  	cJSon += '	}'
	EndIf
  	
  	If !Empty(oAnyProd:cNBM)
	  	cJSon += ', "nbm": {'
	   	cJSon += ' 		"id": '+oAnyProd:cNBM	
	  	cJSon += '	}'
	EndIf
	
Return cJSon

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: GetProd
Tipo		: MTH = Metodo
Descri��o	: Cria os produtos no AnyMarket
Par�metros	: Nil
Retorno		: Nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 16/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Method GetProd() Class AnyProduto	
	Local cRespJSON		:= ''
	Local cHeaderRet 	:= ''
	Local cUrl			:= ::cURLBase+'/products'
	Local cUrlSku		:= ::cURLBase+'/skus'
	Local nI, nJ		:= 0
	Local lAchou		:= .F.
	Local cProduto		:= ''
	Local oSkus			:= AnySku():New()
	Local oCaracte		:= AnyCaracte():New()
	
	//A vari�vel � o tipo privada para o comando Type funcionar
	Private oJsProduto	:= Nil
	
	::cIdWeb := AllTrim(::cIdWeb)
	::cCodigo:= AllTrim(::cCodigo)
	::cIdSku := AllTrim(::cIdSku)
	
	If AllTrim(::cIdWeb) == '' .And. AllTrim(::ccodigo) == '' .and. AllTrim(::cIdSku) == ''
		Return
	EndIf
	
	If AllTrim(::cIdWeb) <> ''
		cRespJSON 	:= HTTPGET(cUrl+'/'+::cIdWeb,,,::aHeadStr,@cHeaderRet)
		If cRespJSON <> NIL .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)
			lAchou := .T.
		EndIf
	EndIf
	
	//Localiza o produto pelo partnerID do Sku
	If !lAchou .And. AllTrim(::cCodigo) <> ''
		cRespJSON 	:= HTTPGET(cUrl+'/?sku='+::cCodigo,,,::aHeadStr,@cHeaderRet)
		If cRespJSON <> NIL .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)
			lAchou := .T.
		EndIf
	EndIf
	
	//Localiza o produto pelo id do Sku
	If !lAchou .And. AllTrim(::cIdSku) <> ''
		cRespJSON 	:= HTTPGET(cUrlSku+'/'+::cIdSku,,,::aHeadStr,@cHeaderRet)
		If cRespJSON <> NIL .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)
			
			FWJsonDeserialize(cRespJSON,@oJsProduto)
			
			If Type("oJsProduto:PARTNERID") <> 'U'				
				cRespJSON 	:= HTTPGET(cUrl+'/?sku='+cValToChar(oJsProduto:PARTNERID),,,::aHeadStr,@cHeaderRet)
				If cRespJSON <> NIL .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)
					lAchou := .T.
				EndIf
			EndIf
		EndIf
	EndIf

	If lAchou
		FWJsonDeserialize(cRespJSON,@oJsProduto)
		If Type('oJsProduto:Content') == 'U'
			lAchou := .F.
		EndIf
	EndIf
	
	If lAchou	
		For nI := 1 to Len(oJsProduto:Content)
		
			::cIdWeb := cValToChar(oJsProduto:Content[nI]:ID)
			
			If Type('oJsProduto:Content['+cValToChar(nI)+']:Brand:Id')!='U'
				::cIdMarca		:= oJsProduto:Content[nI]:Brand:Id
			EndIf	
			
			If Type('oJsProduto:Content['+cValToChar(nI)+']:Brand:Name')!='U'
				::cDescMarca	:= oJsProduto:Content[nI]:Brand:Name
			EndIf	
			
			If Type('oJsProduto:Content['+cValToChar(nI)+']:Category:Id')!='U'
				::cIdCateg		:= oJsProduto:Content[nI]:Category:Id
			EndIf	
			
			If Type('oJsProduto:Content['+cValToChar(nI)+']:Category:Name')!='U'
				::cDescCate		:= oJsProduto:Content[nI]:Category:Name
			EndIf
			
			If Type('oJsProduto:Content['+cValToChar(nI)+']:title')!='U'
				::cDesc			:= oJsProduto:Content[nI]:title
			EndIf	
			
			If Type('oJsProduto:Content['+cValToChar(nI)+']:weight')!='U'
				::nPeso			:= oJsProduto:Content[nI]:weight
			EndIf	
			
			If Type('oJsProduto:Content['+cValToChar(nI)+']:width')!='U'
				::nLargura		:= oJsProduto:Content[nI]:width
			EndIf	
			
			If Type('oJsProduto:Content['+cValToChar(nI)+']:length')!='U'
				::nComprimento	:= oJsProduto:Content[nI]:length
			EndIf	
			
			If Type('oJsProduto:Content['+cValToChar(nI)+']:width')!='U'
				::nAltura		:= oJsProduto:Content[nI]:width
			EndIf	
			
			If Type('oJsProduto:Content['+cValToChar(nI)+']:warrantyTime')!='U'
				::nTempGarantia	:= oJsProduto:Content[nI]:warrantyTime
			EndIf	
			
			If Type('oJsProduto:Content['+cValToChar(nI)+']:warrantyText')!='U'
				::cDesGarantia	:= oJsProduto:Content[nI]:warrantyText
			EndIf	

			If Type('oJsProduto:Content['+cValToChar(nI)+']:priceFactor')!='U'
				::nMarkup		:= oJsProduto:Content[nI]:priceFactor
			EndIf	

			If Type('oJsProduto:Content['+cValToChar(nI)+']:calculatedPrice')!='U'
				::nTipoPreco	:= iif(oJsProduto:Content[nI]:calculatedPrice, 1, 2) //= 1 = MANUAL 2 = AUTOM�TICO
			EndIf	

			If Type('oJsProduto:Content['+cValToChar(nI)+']:description')!='U'
				::cInfomacoes	:= oJsProduto:Content[nI]:description
			EndIf	

			If Type('oJsProduto:Content['+cValToChar(nI)+']:origin:Id')!='U'
				::cOrigem		:= oJsProduto:Content[nI]:origin:Id
			EndIf	

			If Type('oJsProduto:Content['+cValToChar(nI)+']:Model')!='U'
				::cModelo		:= oJsProduto:Content[nI]:Model
			EndIf	

			If Type('oJsProduto:Content['+cValToChar(nI)+']:nbm:id')!='U'
				::cNbm		:= oJsProduto:Content[nI]:nbm:id
			EndIf

			//cProduto := TrataProd(::cCodigo) 
			cProduto := AllTrim(::cCodigo)
			If Type('oJsProduto:Content['+cValToChar(nI)+']:skus')=='A'
				For nJ := 1 to Len(oJsProduto:Content[nI]:skus)
					If Type('oJsProduto:Content['+cValToChar(nI)+']:skus['+cValToChar(nJ)+']:partnerId')!='U'
						::cIdWeb := cValToChar(oJsProduto:Content[nI]:ID)
						oSkus:cIdWeb 	:= cValToChar(oJsProduto:Content[nI]:skus[nJ]:ID) 
						oSkus:cDesc 	:= oJsProduto:Content[nI]:skus[nJ]:title
						oSkus:cCodProd 	:= oJsProduto:Content[nI]:skus[nJ]:partnerId
						oSkus:cCodBarra := oJsProduto:Content[nI]:skus[nJ]:ean
						oSkus:nQde 		:= oJsProduto:Content[nI]:skus[nJ]:amount
						oSkus:nPreco 	:= oJsProduto:Content[nI]:skus[nJ]:price
						::AddSku(oSkus)
					EndIf
				Next
			ElseIf Type('oJsProduto:Content['+cValToChar(nI)+']:skus')!='U'
				If Type('oJsProduto:Content['+cValToChar(nI)+']:skus:partnerId')!='U'					
					::cIdWeb := cValToChar(oJsProduto:Content[nI]:ID)
					oSkus:cIdWeb 	:= cValToChar(oJsProduto:Content[nI]:skus:ID) 
					oSkus:cDesc 	:= oJsProduto:Content[nI]:skus:title
					oSkus:cCodProd 	:= oJsProduto:Content[nI]:skus:partnerId
					oSkus:cCodBarra := oJsProduto:Content[nI]:skus:ean
					oSkus:nQde 		:= oJsProduto:Content[nI]:skus:amount
					oSkus:nPreco 	:= oJsProduto:Content[nI]:skus:price
					::AddSku(oSkus)
				EndIf
			EndIf
			
			If Type('oJsProduto:Content['+cValToChar(nI)+']:characteristics')=='A'
				For nJ := 1 to Len(oJsProduto:Content[nI]:characteristics)
					If Type('oJsProduto:Content['+cValToChar(nI)+']:characteristics['+cValToChar(nJ)+']:titulo')!='U'
						oCaracte:cTitulo 	:= oJsProduto:Content[nI]:characteristics[nJ]:titulo
						oCaracte:cValor 	:= oJsProduto:Content[nI]:characteristics[nJ]:valor
						::AddCaracte(oCaracte)
					EndIf
				Next
			ElseIf Type('oJsProduto:Content['+cValToChar(nI)+']:characteristics:titulo')!='U'
				oCaracte:cTitulo 	:= oJsProduto:Content[nI]:characteristics:titulo
				oCaracte:cValor 	:= oJsProduto:Content[nI]:characteristics:valor
				::AddCaracte(oCaracte)
			EndIf
		Next	
	EndIf

Return lAchou

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: AtuaProduto
Tipo		: MTH = Metodo
Descri��o	: Cria os produtos no AnyMarket
Par�metros	: Nil
Retorno		: Nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 16/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Method AtuaProduto() Class AnyProduto
	Local cRespJSON		:= ''
	Local cHeaderRet	:= ''
	Local cUrl			:= ::cURLBase+'/products'
	Local cJSon			:= ''
	Local cProduto		:= ''
	Local cPrcVen		:= "0"
	Local nPos			:= 0
	Local aMsgErro 		:= {}
	Local oPut			:= Nil
	Local cProdAny		:= ''
	Local nGarantia		:= 0
	Local nContImg		:= 0
	Local oImagem		:= Nil
	Local cIdSku		:= ''
	Local cDescSku		:= ''
	Local cDescricao	:= ''
	Local cCodBar 		:= ''
	Local cCodBarCx 	:= ''
	Local nI 			:= 0
	Local cJsonAlt		:= ''
	Local cJsonInc		:= ''

	Private oJsProduto:= Nil
	
	If AllTrim(::cCodigo) == ''
		Return
	EndIf
	
	cProdAny := AllTrim(::cCodigo)

	If Empty(::cIdWeb)
		If !GetProd(AllTrim(Upper(cProdAny)))
			Return
		EndIf
	EndIf

	cUrl 		+= '/'+::cIdWeb
	cRespJSON 	:= HTTPGet(cUrl,,,::aHeadStr,@cHeaderRet)
	oPut 		:= FWRest():New(cUrl)

	If cRespJSON <> NIL .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)

		cProduto 	:= AllTrim(::cCodigo)
		nGarantia 	:= 0

		cJSon := '	{ '
		cJSon += '"id": '+::cIdWeb +', ' 	
		cJSon += MontaJson(Self)
		
		//Categoria
		If AllTrim(::cIdCateg) <> ''		
			cJSon += ',  	"category": '
			cJSon += '  		{'
			cJSon += '    		"id": "'+AllTrim(::cIdCateg)+'" '	//C�digo da categoria
			cJSon += '  		} '
		EndIf
		
		//Marca
		If Valtype(::cIdMarca) == 'C'
			::cIdMarca := Val(::cIdMarca)
		EndIf
		
		If Valtype(::cIdMarca) == 'N' .AND. ::cIdMarca <> 0
			If ::cIdMarca > 0		
				cJSon += ',  	"brand": '
				cJSon += '  		{'
				cJSon += '    		"id": "'+cValToChar(::cIdMarca)+'" '	//C�digo da categoria
				cJSon += '  		} '
			EndIf
		EndIf
		
		cJSon += ' } '		
		oPut:SetPath('')		
		oPut:Put(::aHeadStr, cJSon)
		cRespJSON := oPut:GetResult()	
		
		If !('200' $ oPut:oResponseH:cStatusCode)
			aMsgErro := {}
			aAdd(aMsgErro, 'Atualiza��o Produto')
			aAdd(aMsgErro, cUrl)
			aAdd(aMsgErro, cRespJSON)
			aAdd(aMsgErro, cJSon)
			Self:EmailErro(aMsgErro)
		EndIf
		
		FreeObj(oPut)
				
		//AtualiSKU
		cRespJSON := HTTPGet(cUrl+'/skus',,,::aHeadStr,@cHeaderRet)
		If cRespJSON <> NIL .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)
			FWJsonDeserialize(cRespJSON,@oJsProduto)			
		
			If Type('oJsProduto') !='U' .AND. Len(::aSkus) > 0
				For nI := 1 to Len(::aSkus)
					cDescricao	:= Replace(cDescricao,"�","''")
			
					oSku := ::aSkus[nI]
					
					If ValType(oSku) <> 'O'
						Loop
					EndIf
					
					If !Empty(oSku:cIdWeb)
						cJsonAlt := ''
				
						cJsonAlt += ' {'
				
						If !Empty(oSku:cCodBarra)
							cJsonAlt += '	 "ean": "'+AllTrim(oSku:cCodBarra)+'",'	//C�digo de barras
						EndIf
						
						cJsonAlt += '	   	"canEditEan": true'				//Edita o c�digo de barras
						cJsonAlt += '	, 	"partnerId": "'+AllTrim(oSku:cCodProd)+'"'	//ID do produto	
						cJsonAlt += '	,	"amount": '+cValToChar(oSku:nQde) 				//Quantidade
						cJsonAlt += '	,	"title": "'+AllTrim(oSku:cDesc)+'"'		//T�tulo SKU
						cPreco := StrTran( cValToChar( Round(oSku:nPreco,2)), ',', '.')
						cJsonAlt += '	, 	"price": '+cPreco				//Pre�o de venda
										
						cJsonAlt += ' }'
						
						oPut := FWRest():New(cUrl+'/skus/'+oSku:cIdWeb)
					
						oPut:SetPath('')		
						oPut:Put(::aHeadStr, cJsonAlt)
						cRespJSON := oPut:GetResult()	
						
						If !('200' $ oPut:oResponseH:cStatusCode)
							aMsgErro := {}
							aAdd(aMsgErro, 'Atualiza��o do SKU na Atualiza��o do Produto')
							aAdd(aMsgErro, cUrl)
							aAdd(aMsgErro, cRespJSON)
							aAdd(aMsgErro, cJsonAlt)
							Self:EmailErro(aMsgErro)
						EndIf
						
						FreeObj(oPut)
					Else
				
						cJsonInc := ' {'
				
						If !Empty(oSku:cCodBarra)
							cJsonInc += '	 "ean": "'+AllTrim(oSku:cCodBarra)+'",'	//C�digo de barras
						EndIf
						
						cJsonInc += '	   	"canEditEan": true'				//Edita o c�digo de barras
						cJsonInc += '	, 	"partnerId": "'+AllTrim(oSku:cCodProd)+'"'	//ID do produto	
						cJsonInc += '	,	"amount": '+cValToChar(oSku:nQde) 				//Quantidade
						cJsonInc += '	,	"title": "'+AllTrim(oSku:cDesc)+'"'		//T�tulo SKU
						cPreco := StrTran( cValToChar( Round(oSku:nPreco,2)), ',', '.')
						cJsonInc += '	, 	"price": '+cPreco				//Pre�o de venda
										
						cJsonInc += ' }'	
						
						cRespJSON := HTTPPost(cUrl+'/skus',,cJsonInc,,::aHeadStr,@cHeaderRet)
						
						If !('200' $ cHeaderRet)
							aMsgErro := {}
							aAdd(aMsgErro, 'Inser��o de SKU na Atualiza��o do Produto')
							aAdd(aMsgErro, cUrl)
							aAdd(aMsgErro, cRespJSON)
							aAdd(aMsgErro, cJsonAlt)
							Self:EmailErro(aMsgErro)
						EndIf
						
					EndIf					
				Next
				
			EndIf
		EndIf
	EndIf
				
Return	

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: AllProdutos
Tipo		: MTH = Metodo
Descri��o	: Cria os produtos no AnyMarket
Par�metros	: Nil
Retorno		: Nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 17/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Method AllProdutos() Class AnyProduto	
	Local cRespJSON	:= ''
	Local cHeaderRet 	:= ''
	Local cUrl			:= ::cURLBase+'/products?limit=100'
	Local nI, nJ		:= 0
	Local nCount		:= 0
	
	//A vari�vel � o tipo privada para o comando Type funcionar
	Private oJsProduto	:= Nil

	::aListaProd 	:= {}
	While .T.
		//cTimeIni := Time()
		cHeaderRet 	:= ''
		cRespJSON 	:= HTTPGET(cUrl+'&offset='+cValToChar(nCount),,,::aHeadStr,@cHeaderRet)
		
		If cRespJSON <> NIL .and. ("200 OK" $ cHeaderRet .or. "201 Created" $ cHeaderRet)
			oJsProduto := NiL
			FWJsonDeserialize(cRespJSON,@oJsProduto)			
			
			//Localiza o produto pelo c�digo do SKU
			If Type('oJsProduto:Content') !='U'
				For nI := 1 to Len(oJsProduto:Content)
					If Type('oJsProduto:Content['+cValToChar(nI)+']:skus')!='U'
						For nJ := 1 to Len(oJsProduto:Content[nI]:skus)
							If Type('oJsProduto:Content['+cValToChar(nI)+']:skus['+cValToChar(nJ)+']:partnerId')!='U' 	
								aAdd(::aListaProd, {cValToChar(oJsProduto:Content[nI]:ID);
													, cValToChar(oJsProduto:Content[nI]:skus[nJ]:ID);
													, oJsProduto:Content[nI]:skus[nJ]:partnerId ;	
													, iif(Type('oJsProduto:Content['+cValToChar(nI)+']:category:Id')!='U',; 
														oJsProduto:Content[nI]:category:Id, 0);	
													, iif(Type('oJsProduto:Content['+cValToChar(nI)+']:brand:Id')!='U',; 
														oJsProduto:Content[nI]:brand:Id, 0)})
							EndIf
						Next
					EndIf
				Next
			Else
				Exit
			EndIf
		Else
			Exit
		EndIf

	nCount += 100
	EndDo
Return

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: AllAtuEstoques
Tipo		: MTH = Metodo
Descri��o	: Cria os produtos no AnyMarket
Par�metros	: Nil
Retorno		: Nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 04/12/2015 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Method AllAtuEstoques() Class AnyProduto	
	Local cRespJSON		:= ''
	Local cHeaderRet 	:= ''
	Local cUrl			:= ::cURLBase+'/stocks'
	Local nI		 	:= 0
	Local cJSon			:= ''
	Local aMsgErro		:= {}
	Local cProduto 		:= ''
	Local lAdicionou	:= .F.
	Local oPut			:= Nil
	
	oPut := FWRest():New(cUrl)

	If Len(::aListaProd) == 0
		Self:AllProdutos()
	EndIf
	
	cJSon := '  ['
	For nI := 1 to Len(::aEstoques)
		::cIdSku	:= ::aEstoques[nI, 1]
		
		nPos := aScan(::aListaProd, {|x|AllTrim(x[2]) = AllTrim(::cIdSku)})
		If nPos == 0
			Loop
		EndIf
		
		If lAdicionou
			cJSon += ', '
		EndIf
		
		::cCodigo  	:= ::aListaProd[nPos, 1] 
		::cIdWeb	:= ::aListaProd[nPos, 3]
		
		cJSon += '    {'
		cJSon += '      "id": '+::cIdSku+','		
		cJSon += '      "quantity": '+cValToChar(::aEstoques[nI,2])
		cJSon += '    }'
		lAdicionou := .T.
		
	Next
	
	cJSon += '  ]'

	If Len(::aEstoques) > 0

		oPut:SetPath('')
		
		oPut:Put(::aHeadStr, cJSon)
		cRespJSON := oPut:GetResult()	
		
		If !('204' $ oPut:oResponseH:cStatusCode)
			aMsgErro := {}
			aAdd(aMsgErro, 'Estoque')
			aAdd(aMsgErro, cUrl)
			aAdd(aMsgErro, cRespJSON)
			aAdd(aMsgErro, cJSon)
			Self:EmailErro(aMsgErro)
			
		EndIf
	EndIf		
Return

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: AllAtuPreco
Tipo		: MTH = Metodo
Descri��o	: Cria os produtos no AnyMarket
Par�metros	: Nil
Retorno		: Nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 17/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Method AllAtuPreco() Class AnyProduto	
	Local cRespJSON		:= ''
	Local cHeaderRet 	:= ''
	Local cUrl			:= ::cURLBase+'/stocks'
	Local nI		 	:= 0
	Local cJSon			:= ''
	Local aMsgErro		:= {}
	Local cProduto 		:= ''
	Local oPut			:= Nil
	Local lEntrou		:= .F.
	
	If Len(::aListaProd) == 0
		Self:AllProdutos()
	EndIf
	
	oPut := FWRest():New(cUrl)
	
	If Len(::aPrecos) == 0
		Return
	EndIf

	cJSon := '  ['+CHR(13)+CHR(10)
	For nI := 1 to Len(::aPrecos)
		::cIdSku := AllTrim(::aPrecos[nI, 1])
		//cProduto := TrataProd(cProduto)
		
		nPos := aScan(::aListaProd, {|x|AllTrim(x[2]) == ::cIdSku})
		If nPos == 0
			Loop
		EndIf

		::cIdWeb	:= ::aListaProd[nPos, 1]
		::cCodigo 	:= ::aListaProd[nPos, 3]

		If lEntrou
			cJSon += ', '
		EndIf

		cJSon += '    {'
		cJSon += '      "id": '+::cIdSku+','		
		cJSon += '      "cost": '+cValToChar(::aPrecos[nI,2])
		cJSon += '    }'+CHR(13)+CHR(10)
		lEntrou := .T.

	Next

	cJSon += '  ]'	
	oPut:SetPath('')

	oPut:Put(::aHeadStr, cJSon)
	cRespJSON := oPut:GetResult()	

	If !('204' $ oPut:oResponseH:cStatusCode)				
		aMsgErro := {}
		aAdd(aMsgErro, 'Estoque')
		aAdd(aMsgErro, cUrl)
		aAdd(aMsgErro, cRespJSON)
		aAdd(aMsgErro, cJSon)
		Self:EmailErro(aMsgErro)		
	EndIf

Return

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: TrataProd
Tipo		: Fun��o est�tica
Descri��o	: Formata o c�digo do produto para n�o gerar erro no AnyMarket
Par�metros	: cExp1 - C�dgo de produto
Retorno		: String
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 17/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
/*
Static Function TrataProd(cProduto)
	If AllTrim(cProduto) == ''
		Return ''
	EndIf

	cProduto := AllTrim(cProduto)
 	cProduto := Replace(cProduto," ","_")
 	cProduto := Replace(cProduto,"+","_")
 	cProduto := Replace(cProduto,".","X")
 	cProduto := Replace(cProduto,"-","Z")
 	cProduto := Replace(cProduto,"/","W")
 	
Return cProduto
*/
/*
------------------------------------------------------------------------------------------------------------
Fun��o		: TrataDescr
Tipo		: Fun��o est�tica
Descri��o	: Formata o c�digo do produto para n�o gerar erro no AnyMarket
Par�metros	: cExp1 - C�dgo de produto
Retorno		: String
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 17/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function TrataDescr(cTexto)
	Default cTexto := ''
	
	If AllTrim(cTexto) == ''
		Return cTexto
	EndIf

	cTexto := Replace(cTexto, chr(13)+chr(10), '</p><p>')
	cTexto := Replace(cTexto, chr(10)+chr(13), '</p><p>')
	cTexto := Replace(cTexto, '"', '&#34;')
	
Return cTexto

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: RetiraCaracEsp
Tipo		: Fun��o est�tica
Descri��o	: Formata o c�digo do produto para n�o gerar erro no AnyMarket
Par�metros	: cExp1 - C�dgo de produto
Retorno		: String
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 17/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function RetiraCaracEsp(_sOrig)
   local _sRet := _sOrig
   
   _sRet = strtran (_sRet, "�", "a")
   _sRet = strtran (_sRet, "�", "e")
   _sRet = strtran (_sRet, "�", "i")
   _sRet = strtran (_sRet, "�", "o")
   _sRet = strtran (_sRet, "�", "u")
   _SRET = STRTRAN (_SRET, "�", "A")
   _SRET = STRTRAN (_SRET, "�", "E")
   _SRET = STRTRAN (_SRET, "�", "I")
   _SRET = STRTRAN (_SRET, "�", "O")
   _SRET = STRTRAN (_SRET, "�", "U")
   _sRet = strtran (_sRet, "�", "a")
   _sRet = strtran (_sRet, "�", "o")
   _SRET = STRTRAN (_SRET, "�", "A")
   _SRET = STRTRAN (_SRET, "�", "O")
   _sRet = strtran (_sRet, "�", "a")
   _sRet = strtran (_sRet, "�", "e")
   _sRet = strtran (_sRet, "�", "i")
   _sRet = strtran (_sRet, "�", "o")
   _sRet = strtran (_sRet, "�", "u")
   _SRET = STRTRAN (_SRET, "�", "A")
   _SRET = STRTRAN (_SRET, "�", "E")
   _SRET = STRTRAN (_SRET, "�", "I")
   _SRET = STRTRAN (_SRET, "�", "O")
   _SRET = STRTRAN (_SRET, "�", "U")
   _sRet = strtran (_sRet, "�", "c")
   _sRet = strtran (_sRet, "�", "C")
   _sRet = strtran (_sRet, "�", "a")
   _sRet = strtran (_sRet, "�", "A")
   
   _sRet = strtran (_sRet, "�", ".")
   _sRet = strtran (_sRet, "�", ".")
   _sRet = strtran (_sRet, chr (9), " ") // TAB
   _sRet = strtran (_sRet, '�', "i")
   _sRet = strtran (_sRet, '�', "''")    // polegadas
   _sRet = strtran (_sRet, '"', "")
   
return _sRet

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: AddIDSku
Tipo		: Fun��o est�tica
Descri��o	: Adiciona o ID do Sku no objeto
Par�metros	: oExp1 - Objeto Produto
			  oExp2 - Objeto Sku
Retorno		: Nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 19/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function AddIDSku(oAnyProduto, oAnySku)
	Local nI := 0
	Local oSkuArray := nil
	
	Default oSku := nil
	
	If Len(oAnyProduto:aSKUs) == 0
		Return
	EndIf
	
	If oAnySku == nil
		Return
	EndIf

	For nI := 1 to Len(oAnyProduto:aSKUs)
		oSku := oAnyProduto:aSKUs[nI]
		
		If oSku:cCodProd == oAnySku:PartnerId
			oSku:cIdWeb := cValToChar(oAnySku:Id) 
			Exit
		EndIf
	Next

Return

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: AnySku
Tipo		: CLS = Classe
Descri��o	: Classe de Skus do produto
Par�metros	: Nil
Retorno		: Nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 16/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Class AnySku From AnyAcesso
	//SKU
	Data cIdWeb
	Data cDesc
	Data cCodProd
	Data cCodBarra
	Data nQde
	Data nPreco
	  	
	Method New() CONSTRUCTOR
	Method Adiciona()
	Method GetSku()
	Method CriaSku()
	Method AtualiSku()

EndClass

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: New
Tipo		: MTH = Metodo
Descri��o	: Construtor do Objeto AnySku
Par�metros	: Nil
Retorno		: Nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 17/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Method New() Class AnySku
	_Super:New()
	
	::cIdWeb	:= ''
	::cDesc		:= ''
	::cCodProd	:= ''
	::cCodBarra	:= ''
	::nQde		:= 0
	::nPreco	:= 0
	
Return Self

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: Adiciona
Tipo		: MTH = Metodo
Descri��o	: Adiciona nova caracteristica ao produto
Par�metros	: Nil
Retorno		: Nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 17/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Method Adiciona() Class AnySku
	If !AnaliCBarra(::cCodBarra)
		::cCodBarra := ''
	EndIf
	
	If ::nQde < 0
		::nQde := 0
	EndIf
	
	::aSKUs(Self)
	
Return 

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: AnaliCBarra
Tipo		: Fun��o est�tica
Descri��o	: Analisa se o c�digo de barras � v�lido, caso n�o seja, n�o cadastra no SKU
Par�metros	: cExp1 : C�digo de barras
Retorno		: Boolean
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 17/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Static Function AnaliCBarra(cCodBar)
	Local cCodBarCx	:= ''
	
	Default cCodBar := ''
	
	If Empty(cCodBar)
		Return .F.
	EndIf
	 
	If Len(AllTrim(cCodBar)) == 13
		nDig := EANDIGITO(cCodBar) 
	 	
		If nDig == SubStr(cCodBar, 13, 1)
			Return .T.			
		EndIf
	EndIf

Return .F.

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: AnyCaracte
Tipo		: CLS = Classe
Descri��o	: Classe de caracter�sticas do produto no Anymarket
Par�metros	: Nil
Retorno		: Nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 16/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Class AnyCaracte From AnyAcesso
	//Data cIdWeb	
	Data cTitulo
	Data cValor
	  	
	Method New() CONSTRUCTOR
	Method Adiciona()

EndClass

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: New
Tipo		: MTH = Metodo
Descri��o	: Construtor do Objeto AnyCaracte
Par�metros	: Nil
Retorno		: Nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 17/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Method New() Class AnyCaracte
	_Super:New()
	
	::cTitulo	:= '' 
	::cValor	:= ''
	
Return Self

/*
------------------------------------------------------------------------------------------------------------
Fun��o		: Adiciona
Tipo		: MTH = Metodo
Descri��o	: Adiciona nova caracteristica ao produto
Par�metros	: Nil
Retorno		: Nil
------------------------------------------------------------------------------------------------------------
Atualiza��es:
- 17/04/2016 - Henrique - Constru��o inicial do fonte
------------------------------------------------------------------------------------------------------------
*/
Method Adiciona() Class AnyCaracte
	::aCaracte(Self)
	
Return