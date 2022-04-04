// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.0;

import "./Counters.sol";
import "./ReentrancyGuard.sol";
import "./Strings.sol";
// import "./ERC721.sol";
// import "./SafeMath.sol";


interface bep20Token{
    function decimals() external view returns (uint256) ;
    function balanceOf(address account) external view returns  (uint256)  ;
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

interface IERC721{
    function ownerOf(uint256 tokenId)external  view  returns (address);
    function balanceOf(address owner)external  view  returns (uint256);
    function transferFrom( address from, address to, uint256 tokenId )external payable ;
    function customMintNFT(address addr ) external payable returns (uint256);
    function totalSupply() external view returns (uint256) ;
}

contract Presale is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter public _mintNftAmount ;
    Counters.Counter public _packagesSold ;

    address public nftContract ;
    address payable public owner;
    uint256 MIN_PACKET_PRICE = 10000000000000000;
    

    /** PACKETS List  ***/    
    // packet info
    struct PacketType{
        uint8 totalAmount ;
        uint8 treasureNftPerPackage ;
        uint8 purchasedAmount ;
        uint8 rarity;
        uint rarityChance;
        uint256 price;
    }
    // packets
    PacketType[]  public packetList  ;

    event newPacketEvent (
        uint8 totalAmount ,
        uint8 treasureNftPerPackage ,
        uint8 purchasedAmount ,
        uint8 rarity,
        uint rarityChance,
        uint256 price
    );
    /**END PACKETS List  ***/ 


    /* PURCHASED PACKS */
    struct PurchasedPack {        
        uint256 itemId;
        uint8 rarity;
        uint256 pseudoRandomDNA;
        address minter;
    }

    PurchasedPack[]  public   purchasedNftList ;

    event PurchasedPackEvent (
        PurchasedPack[]
    );
    /* END PURCHASED PACKS */

    /* Start Referal CODE*/
    struct InfluencerData {        
        uint8 discount;
        uint8 assignment;
        address wallet;
        string code;
    }
    mapping(string => InfluencerData) public codes ;

    //block.number   tx.origin
    struct saleCodeData{
        address origin;
        uint256 blockNumber;
        uint256 packedPrice;
        uint256[] nfts;
    }
    mapping(string => saleCodeData[]  )public salesByCode;
    /* END Referal CODE*/

    // Get attributes SIZE
    uint8 constant ADN_SECTION_SIZE = 2;

    constructor( ) {
        owner = payable(msg.sender);
        nftContract =   address(0x610b0a6869a9B7F3bcd76E09A5A0c31aEF288083);

        //  quantity, itemAmount,  rarity,  rarityChance ,  price 
        setNewPacket( 0, 0, 0 ,0, 10000000000000000  ); // precio solo para cumplir las restricciones
        setNewPacket( 99,3, 2 ,50, 50000000000000000  ); // 0.05
        setNewPacket( 99,3, 2 ,50, 100000000000000000  ); //0.1
        setNewPacket( 99,3, 3 ,50, 200000000000000000  ); //0.2
    }

    function substring(string memory str, uint startIndex, uint endIndex) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex-startIndex);
        for(uint i = startIndex; i < endIndex; i++) {
            result[i-startIndex] = strBytes[i];
        }
        return string(result);
    }

    /**  @dev only Owner */
    modifier onlyOwner()  {
        require( msg.sender == owner , "you shall not pass" );
        _;
    }

    /*New Owner*/
    function setOwner(address payable newOwner)public onlyOwner payable
    {
        owner = newOwner;
    }

    /* change NFT CONTRACT -> only Emergency */
    function setNftAddress( address newAddr)public payable onlyOwner
    {
        nftContract = newAddr;
    }

    // Get Purchases amount
    // function getAmountOfPurchases() 
    // public view returns(uint256)
    // {
    //     return _mintNftAmount.current();
    // }

    //Set Min Packet Price
    function setMinPacketPrice( uint256 minPrice)public payable onlyOwner
    {
        MIN_PACKET_PRICE = minPrice;
    }
    

    /* START Referal CODE*/
    function GenerateReferalCode(address walletAddress)internal pure returns(string memory)
    {
        return substring( Strings.toString( deterministicPseudoRandomDNA( 0 , walletAddress ) ) , 0, 18   );
    }

    // View Code Info By Wallet
    function viewMyReferalCodeInfo(address walletAddress)public view   returns(string memory)
    {
        string memory tempCode = GenerateReferalCode(  walletAddress ) ;
        require(codes[tempCode].wallet != address(0) ,"You have Not a Referal Code, create it in the setInfluencerData_Public function ");
        
        string memory separator= ","; 
        string memory retorno = string(abi.encodePacked( 
            "discount: %" , Strings.toString( codes[tempCode].discount  ),separator ,
            "assignment: %", Strings.toString( codes[tempCode].discount  ), separator ,
            "code:", tempCode   
           // "wallet:",  abi.encodePacked(codes[tempCode].wallet)   , separator ,
           // "}"
        ));
        return retorno;
    }

    // View Code Info By Code = struct
    function viewMyReferalAddressCodeInfo(address walletAddress)public view returns(InfluencerData memory)
    {
        string memory tempCode = GenerateReferalCode(  walletAddress ) ;
        require(codes[tempCode].wallet != address(0) ,"You have Not a Referal Code, create it in the setInfluencerData_Public function ");             
        return codes[tempCode];
    }
    function viewMyReferalAddressCode(address walletAddress)public view returns(string memory)
    {
        string memory code = GenerateReferalCode(  walletAddress ) ;
        require(codes[code].wallet != address(0) ,"You have Not a Referal Code, create it in the setInfluencerData_Public function "); 
        return code;
    }

    // View Code Info By Code = struct
    function viewMyReferalCodeInfo(string memory code)public view   returns(InfluencerData memory)
    {
        require(codes[code].wallet != address(0) ,"You have Not a Referal Code, create it in the setInfluencerData_Public function ");          
        return codes[code];
    }

    // View list of transactions by referal code
    function viewCodeSoldPackages(string memory code)public view   returns( saleCodeData[]  memory)
    {
        return salesByCode[code];
    }

    // View list of transactions by referal code
    function viewCodeSoldPackagesLength(string memory code)public view   returns( uint256)
    {
        return salesByCode[code].length;
    }



    function setInfluencerData_Private( string memory code, uint8 assignment, uint8 discount,address wallet   )public payable onlyOwner
    {
        codes[code] = InfluencerData(discount,assignment,wallet,code);
    }

    function setInfluencerData_Public(    )public payable returns(string memory)
    {
        string memory code = GenerateReferalCode(   msg.sender   );
        uint8 assignment = 5; //percent 
        uint8 discount = 5; //percent
        address wallet = msg.sender;
        codes[code] = InfluencerData(discount,assignment,wallet,code);
        return code;
    }
    /* END Referal CODE*/


    // This pseudo random function is determistic and should not be used on production
    function deterministicPseudoRandomDNA(uint256 _tokenId, address _minter)
        public
        pure
        returns (uint256)
    {
        uint256 combinedParams = _tokenId + uint160(_minter);
        bytes memory encodedParams = abi.encodePacked(combinedParams);
        bytes32 hashedParams = keccak256(encodedParams);

        return uint256(hashedParams);
    }

    function _getDNASection(uint256 _dna, uint8 _rightDiscard)
        public
        pure
        returns (uint8)
    {
        return
            uint8(
                (_dna % (1 * 10**(_rightDiscard + ADN_SECTION_SIZE))) /
                    (1 * 10**_rightDiscard)
            );
    }


    /*Definir nuevo Paquete de Compra
        quantity: total de packetes
        itemAmount: itemNfts minteables por paquete
        rarity: rareza del paquete
        rarityChance: probabilidad de que el item sea acorde a la rareza
        price: precio BNB
    */
    function setNewPacket(  uint8 quantity,uint8 itemAmount, uint8 rarity, uint8 rarityChance , uint256 price  ) public payable onlyOwner
    {
        require( price >= MIN_PACKET_PRICE ,"Monto Erroneo" );
        packetList.push( PacketType(quantity,itemAmount,0,rarity,rarityChance, price) );

        emit newPacketEvent( quantity,itemAmount,0,rarity,rarityChance, price );
    }

    //ajustar propiedades del paquete
    function replaceNewPacket(uint8 index ,uint8 itemAmount,   uint8 quantity, uint8 rarity , uint8 rarityChance, uint256 price  ) public payable onlyOwner
    {
        require( price >= MIN_PACKET_PRICE ,"Monto Erroneo" );
        require(index > 0,"No puedes editar index 0");
        packetList[index] = PacketType(quantity,itemAmount,0,rarity,rarityChance, price) ;

        emit newPacketEvent( quantity,itemAmount,0,rarity,rarityChance, price ) ;
    }

    // Listar paquetes disponibles
    function getPacketList() public view returns(  PacketType[] memory  ){
        return packetList;
    } 


    // Preview Final Price with applied Discount
    function getDiscountPrice(uint8 packetId, string memory referalCode)public view returns(uint256)
    {
        uint256 discountPrice = packetList[packetId].price;
        if(codes[referalCode].wallet != address(0))
        {
            discountPrice = packetList[packetId].price - (   (packetList[packetId].price  / 100 ) * codes[referalCode].discount  ) ;
        }

        return discountPrice;
    }

    /*
    Compra de Items con preDefinicion de Rareza
    Todo exceso de pago es retornado inmediatamente
    */
    function buy(uint8 packetId, string memory referalCode )
    public payable nonReentrant returns (PurchasedPack[] memory)
    {
        uint256 discountPrice =  getDiscountPrice(  packetId, referalCode) ;
        
        require(packetList[packetId].totalAmount > packetList[packetId].purchasedAmount ,"Limite Excedido" );
        require(  msg.value >= discountPrice    ,"Pago Erroneo" ); // && msg.value <= packetList[packetId].price
        distributeCoin(   discountPrice  ,  referalCode  );

        packetList[packetId].purchasedAmount = packetList[packetId].purchasedAmount +1;
        PurchasedPack[] memory created  =  new PurchasedPack[](  packetList[packetId].treasureNftPerPackage  ); // +1 
        uint256[] memory items = new uint256[](packetList[packetId].treasureNftPerPackage);

        //Mint NFTS 
        for (uint8 i = 0; i < packetList[packetId].treasureNftPerPackage ; i++)
         {
            uint256 tokenId = IERC721(nftContract).customMintNFT(  msg.sender );
            uint256 dna = deterministicPseudoRandomDNA(  block.number + _mintNftAmount.current() + tokenId , msg.sender  );
            
            uint8 rarity = 1;
            uint8 dnaSegment= 0;
            if(i==0){
                rarity = packetList[packetId].rarity;
            }else{
                dnaSegment = _getDNASection( dna, i );
                rarity = getRarityByDna(packetList[packetId].rarityChance, packetList[packetId].rarity, dnaSegment )  ;
            }
            
            items[i] = tokenId;
            created[ i ] =  PurchasedPack( tokenId ,rarity, _getDNASection( dnaSegment, i ) ,  msg.sender)   ;  
            purchasedNftList.push( created[ i ]  ) ;  
            _mintNftAmount.increment();
        }
        
        if(codes[referalCode].wallet != address(0))
        {
            salesByCode[referalCode].push( saleCodeData(tx.origin , block.number ,discountPrice , items  )   );         
        }

        _packagesSold.increment();
        emit PurchasedPackEvent(created);
        return created;
    }

    /*Determine rarity*/
    function getRarityByDna(uint probability, uint8 rarity, uint256 dnaSegment)
    public pure returns(uint8)
    {   
        require(dnaSegment<=100 ,"Dna Segmen No Valido");
        if(probability==100){
            return rarity;
        }

        uint changeDiff = 100 -probability;
        uint firstDowngrade = probability  + ( changeDiff / 2 ) ;

        if(dnaSegment <= probability){
            return rarity;
        }else if(dnaSegment>probability && dnaSegment<=firstDowngrade ){
            return (rarity -1 > 0)? rarity -1: 1  ;
        }else{
            return (rarity -2 > 0)? rarity -2: 1  ;
        }
    }


    /* START DISTRIBUCION DE TOKENS */    
    function distributeCoin(uint256 price ,string memory referalCode  ) 
    internal  
    {
        uint256 influencerPayment = 0;
        uint256 ownerPayment = price;

        if(codes[referalCode].wallet != address(0))
        {
            influencerPayment = ( price /100) * codes[referalCode].assignment;
            ownerPayment = price - influencerPayment; 

            
        }

        // Garantizar pago a Owner (Reentrant)
        payable(owner).transfer(ownerPayment);
        if(influencerPayment>0)
        {
            payable(codes[referalCode].wallet ).transfer(influencerPayment);
        }

        if(msg.value > price){
            payable(   msg.sender     ).transfer(   msg.value - price     );
        }
    }
    /* END DISTRIBUCION DE TOKENS */

}