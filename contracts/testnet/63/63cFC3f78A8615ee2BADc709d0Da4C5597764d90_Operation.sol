/**
 *Submitted for verification at BscScan.com on 2022-06-07
*/

// SPDX-License-Identifier: Operation
pragma solidity ^0.8.0;

interface GlodContract{
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
}
interface NftContract{
    function toMint(address to_) external returns (bool);
    function toMints(address to_,uint256 amount_) external returns (bool);
    function toTransfer(address from_,address to_,uint256 tokenId_) external returns (bool);
    function toBurn(uint256 tokenId_) external returns (bool);
    function tokenIdType(uint256 tokenId_) external returns (uint256);
    function ownerOf(uint256 tokenId) external view  returns (address);
    function balanceOf(address owner) external view  returns (uint256);
}
interface Nft1155Contract{
    function tomint(address address_,uint256 id_,uint256 amount_,uint256 type_) external returns (bool);
    function toBurn(address address_,uint256 id_,uint256 amount_) external returns (bool);
    function toTransfer(address from_,address to_,uint256 id_,uint256 amount_) external returns (bool);
    function balanceOf(address account, uint256 id) external view  returns (uint256);
    
}
interface Team{
    function team(address from_) external returns (address);
    function bindingWhite(address from_ , address to_) external returns (bool);
}

//中介合约 Operation.sol
contract Operation{
    address public TeslaModel3Contract = address(0xf1c4680Fc0bd93Affc2C75970bc5Bc324d97D58f) ;      //Model3合约地址
    address public TeslaModelyContract = address(0x0f90b74bEf13d994CAf9356E7CE598AFb24dE4c4)  ;      //Modely合约地址
    address public TeslaModelxContract = address(0x16dD89A6c6955CaBCD32069F6bBc0eB5fD31F750)  ;      //Modelx合约地址
    address public TeslaModelsContract = address(0x30066b876E190FA7Ab8660e0bB080BD647f5fB8F)  ;      //Models合约地址
    address public TeslaRoadsterContract = address(0xA839a9Ec6aAB4D4146F6455aB1b826295Dabc45A)  ;    //Roadster合约地址
    address public TeslaSpaceXContract = address(0xCB6EAaEfff1a67d4a4E177cC68ec25EF76EF7d07)  ;      //SpaceX合约地址
    address public BoxContract = address(0xa78ecaE8701e59c890e5ea1101Ce85f02724bF69)  ;             //盲盒合约地址 
    address public OriginationContract = address(0x210442bE87752E9cbe6f79bbba2a9E64046cce97) ;       //初始股东卡
    address public OrdinaryContract = address(0xD31adBe08C287b095e16e7b20Be9Ed22B999de4C) ;          //股东卡
    address public TeamContract = address(0xB75A65cf05B07A2E9a837F210E9e2cAbc73a810F) ;             //上下级关系 
    address public CollectionAddress = address(0x00) ;         //收款地址

    /**
     * USDT地址 
    */
    address public UsdtAddress = address(0xCfC9946E169AC0721698Db6D0FCD4c90Bb46C1e3);
    /**
     * 管理员
    */
    address public _owner;
    modifier Owner {   //管理员
        require(_owner == msg.sender);
        _;
    }
    /**
     * 设定盲盒价格
    */
    uint256 public PriceFeng = 1;
    uint256 public PriceJing = 100;
    

    /**
     * 设定股东卡价格
    */
    uint256 public PriceCard = 1000;
    uint256 public PriceCardVip = 5000;

    /**
     * 推荐购买股东卡人数;
    */
    mapping(address=>mapping(address=>bool)) public RePurchase;
    mapping(address=>uint256) public RePurchaseQuantity;

    /**
     * 购买道具事件;
     * address_     购买地址;
     * proptype_    道具类型  1 fbox   2 jbox  3 card  4 cardvip;
     * amount_      购买数量;
    */

    //发布购买日志
    event buyProp(address address_,uint256 proptype_,uint256 amount_,uint256 price_);

    /**
     * 构造函数
     * parameter   address     CollectionAddress_       收款地址
    */
    constructor(address CollectionAddress_){
        CollectionAddress = CollectionAddress_;
        _owner = msg.sender; //默认自己为管理员
    }
    /**
    *   修改管理员  权限    Owner
    *   owner_  新管理员地址
    */
    function setOwner(address owner_) public Owner returns (bool){
        _owner = owner_;
        return true;
    }
    /**
    *   修改收款地址  权限    Owner
    *   CollectionAddress_  新的收款地址
    */
    function setCollectionAddress(address CollectionAddress_) public Owner returns (bool){
        CollectionAddress = CollectionAddress_;
        return true;
    }
    /**
    *   修改盲盒价格       权限    Owner
    *   newPrice_         新的价格
    *   type_             盲盒种类  1 锋盒  2 镜盒
    */
    function setPriceBlindBox(uint256 newPrice_ , uint256 type_) public Owner returns (bool){
        if(type_ == 1){
            PriceFeng = newPrice_;
        }else if(type_ == 2){
            PriceJing = newPrice_;
        }else{
            require(false, "Parameter error");
        }
        return true;
    }

    /**
    *   修改股东卡价格       权限    Owner
    *   newPrice_         新的价格
    *   type_             卡种类  1 普通  2 创世
    */
    function setPriceCard(uint256 newPrice_ , uint256 type_) public Owner returns (bool){
        if(type_ == 1){
            PriceCard = newPrice_;
        }else if(type_ == 2){
            PriceCardVip = newPrice_;
        }else{
            require(false, "Parameter error");
        }
        return true;
    }
    /**
    *   买盲盒       ALL
    *   type_       盲盒种类  1 锋盒  2 镜盒
    *   superior_   推荐人地址
    *   quantity_   购买数量
    */
    function buyBlindBox(uint256 type_,address superior_,uint256 quantity_) public returns(bool){
        require(quantity_ <= 10, "Parameter error");
        Team Teams = Team(TeamContract);
        if(Teams.team(msg.sender) == address(0x00)){
            Teams.bindingWhite(msg.sender,superior_);
        }
        GlodContract Glod =  GlodContract(UsdtAddress);
        if(type_ == 1){
            Glod.transferFrom(msg.sender,address(CollectionAddress),PriceFeng * quantity_ * 10**Glod.decimals());
            emit buyProp(msg.sender,1,quantity_,PriceFeng * quantity_);
        }else if(type_ == 2){
            Glod.transferFrom(msg.sender,address(CollectionAddress),PriceJing * quantity_ * 10**Glod.decimals());
            emit buyProp(msg.sender,2,quantity_,PriceFeng * quantity_);
        }else{
            require(false, "Parameter error");
        }
        Nft1155Contract Box =  Nft1155Contract(BoxContract);
        Box.tomint(msg.sender,type_,quantity_,1);
        
        return true;
    }
  
    /**
    *   开盲盒       ALL
    *   id_            1 锋盒  2.镜盒
    *   amount_        数量
    */
    function openBlindBox(uint256 id_,uint256 amount_) public returns(bool){
        Nft1155Contract Box =  Nft1155Contract(BoxContract);
        require(amount_ <= 10, "Parameter error");
        require(Box.balanceOf(msg.sender,id_) >= amount_, "Insufficient number of blind boxes");
        for(uint i = 0; i < amount_ ; i++){
            if(id_ == 1){
                uint256 PoweRand = _PoweRand(0,10000);
                if(PoweRand <= 2){
                    NftContract Tesla = NftContract(TeslaSpaceXContract); 
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
                if(PoweRand > 2 && PoweRand <= 5){
                    NftContract Tesla = NftContract(TeslaRoadsterContract); 
                    require(Tesla.toMint(msg.sender), "Casting failure"); 
                }
                if(PoweRand > 5 && PoweRand <= 10){
                    NftContract Tesla = NftContract(TeslaModelsContract);
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
                if(PoweRand > 10 && PoweRand <= 100){
                    NftContract Tesla = NftContract(TeslaModelxContract);
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
                if(PoweRand > 100 && PoweRand <= 500){
                    NftContract Tesla = NftContract(TeslaModelyContract);
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
                if(PoweRand > 500){
                    NftContract Tesla = NftContract(TeslaModel3Contract);
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
            }else if(id_ == 2){
                uint256 PoweRand = _PoweRand(0,100);
                if(PoweRand <= 2){
                    NftContract Tesla = NftContract(TeslaSpaceXContract);
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
                if(PoweRand > 2 && PoweRand <= 7){
                    NftContract Tesla = NftContract(TeslaRoadsterContract); 
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
                if(PoweRand > 7 && PoweRand <= 15){
                    NftContract Tesla = NftContract(TeslaModelsContract);
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
                if(PoweRand > 15 && PoweRand <= 25){
                    NftContract Tesla = NftContract(TeslaModelxContract);
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
                if(PoweRand > 25){
                    NftContract Tesla = NftContract(TeslaModelyContract);
                    require(Tesla.toMint(msg.sender), "Casting failure");
                }
            }else{
                require(false, "Wrong type of blind box");
            }
        }
        require(Box.toBurn(msg.sender,id_,amount_), "Destroy failed");
        return true;
    }


    /**
    *   买股东卡       ALL
    *   ShareholderContract_         股东卡合约地址   
    *   superior_                   推荐人
    */
    function buyCard(address ShareholderContract_,address superior_) public returns(bool){
        GlodContract Glod =  GlodContract(UsdtAddress);
        Team Teams = Team(TeamContract);
        if(Teams.team(msg.sender) == address(0x00)){
            Teams.bindingWhite(msg.sender,superior_);
        }
        NftContract Shareholder_1 =  NftContract(OrdinaryContract); 
        NftContract Shareholder_2 =  NftContract(OriginationContract); 
        if(ShareholderContract_ == OrdinaryContract){
            Glod.transferFrom(msg.sender,address(CollectionAddress),PriceCard * 10**Glod.decimals());
            emit buyProp(msg.sender,3,1,PriceCard);
            if(!RePurchase[superior_][msg.sender]){
                if(Shareholder_1.balanceOf(superior_) > 0 || Shareholder_2.balanceOf(superior_) > 0){
                    RePurchaseQuantity[superior_] += 1;
                }
                RePurchase[superior_][msg.sender] = true;
            }
            if(RePurchaseQuantity[superior_] == 5){
                Shareholder_1.toMint(superior_);
            }
            Shareholder_1.toMint(msg.sender);
        }else if(ShareholderContract_ == OriginationContract){
            Glod.transferFrom(msg.sender,address(CollectionAddress),PriceCardVip * 10**Glod.decimals());
            emit buyProp(msg.sender,4,1,PriceCardVip);
            Shareholder_2.toMint(msg.sender);
        }else{
            require(false, "Parameter error");
        }
        Nft1155Contract Box =  Nft1155Contract(BoxContract);
        Box.tomint(msg.sender,1,100,2);
        return true;
    }



     
    /**
    * 生成随机数
    */
    function _PoweRand(uint256 min_,uint256 poor_) internal view returns(uint256 PoweRand){
        uint256 random = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)));
        uint256 rand = random % poor_;
        return (min_ + rand);
    }
    function onERC1155Received(address,address,uint256,uint256,bytes calldata) external pure returns(bytes4){
        return bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"));
    }
}