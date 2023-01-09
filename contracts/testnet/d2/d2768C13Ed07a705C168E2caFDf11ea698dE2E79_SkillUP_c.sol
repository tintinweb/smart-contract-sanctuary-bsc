// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
/*
████████╗██╗████████╗██╗███╗░░░███╗██╗████████╗██╗
╚══██╔══╝██║╚══██╔══╝██║████╗░████║██║╚══██╔══╝██║
░░░██║░░░██║░░░██║░░░██║██╔████╔██║██║░░░██║░░░██║
░░░██║░░░██║░░░██║░░░██║██║╚██╔╝██║██║░░░██║░░░██║
░░░██║░░░██║░░░██║░░░██║██║░╚═╝░██║██║░░░██║░░░██║
░░░╚═╝░░░╚═╝░░░╚═╝░░░╚═╝╚═╝░░░░░╚═╝╚═╝░░░╚═╝░░░╚═╝
*/

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./IContracts_TITIMITI.sol";
import "./Details.sol";
import "./MINT_GNFT.sol";
import "./ISkill_c.sol";

contract SkillUP_c is Ownable,Pausable, ISkill_c {
    IContracts_TITIMITI Contr;
    IERC1155 details; 
    IERC1155 mINT_GNFT;

    constructor () {
        Contr=IContracts_TITIMITI(0x998A99E482DFa7c436a39296B16C8d11e0beBFea);
        details = IERC1155(address(Contr.getDetails()));
        mINT_GNFT= IERC1155(address(Contr.getMINT_GNFT()));
    }
    
    uint256[4] private Details_num1 = [0,30,31,32];
    uint256[4] private Details_num2 = [0,31,32,33];

    //востановление износа в зависимости от уровня ремкомплекта
    uint256[] public WearPlus = [0,20,60,100]; 

    //Понижение износа при открытие сундука
    uint256 private Opening_Wear = 10; 

    //колличество сколько деталей нужно для поднятия уровня отмычки
    uint256[4] private SkillUP_Details1 = [0,10,4,3]; 
    uint256[4] private SkillUP_Details2 = [0,2,2,2];  

    uint256[4] private SkillUP_Details1_2 = [0,10,4,3]; 
    uint256[4] private SkillUP_Details2_2 = [0,2,2,2];  

    uint256[4] private SkillUP_Details1_3 = [0,10,4,3]; 
    uint256[4] private SkillUP_Details2_3 = [0,2,2,2];  

    
    //колличество сколько нужно опыта для прокачки 
    uint256[4] public SkillUP_EX_1 =[0,700,1000,1000]; 
    uint256[4] public SkillUP_EX_2 =[0,700,1000,1000]; 
    uint256[4] public SkillUP_EX_3 =[0,700,1000,1000]; 

    //повышение износа при повышении уровня 
    uint256[4] public SkillUP_Wear_1 = [0,30,50,50]; 
    uint256[4] public SkillUP_Wear_2 = [0,30,50,50]; 
    uint256[4] public SkillUP_Wear_3 = [0,30,50,50]; 

    //количество опыта которое дается при открытии сундука
    uint256[11] ChestLevel = [0,10,20,30,8,14,22,30,10,20,30]; //+

    //Function_______________________

    function UP(uint256 Skill_,address sender) public virtual override  {
        require(details.balanceOf(sender, Details_num1[Skill_]) >= SkillUP_Details1[Skill_] &&
        details.balanceOf(sender, Details_num2[Skill_]) >= SkillUP_Details2[Skill_] ,"not enough details");

        details.safeTransferFrom(sender, Contr.getStock(), Details_num1[Skill_], SkillUP_Details1[Skill_], "");
        details.safeTransferFrom(sender, Contr.getStock(), Details_num2[Skill_], SkillUP_Details2[Skill_], "");
        }

    function UP_2(uint256 Skill_,address sender) public virtual override  {
        require(details.balanceOf(sender, Details_num1[Skill_]) >= SkillUP_Details1_2[Skill_] &&
        details.balanceOf(sender, Details_num2[Skill_]) >= SkillUP_Details2_2[Skill_] ,"not enough details");

        details.safeTransferFrom(sender, Contr.getStock(), Details_num1[Skill_], SkillUP_Details1_2[Skill_], "");
        details.safeTransferFrom(sender, Contr.getStock(), Details_num2[Skill_], SkillUP_Details2_2[Skill_], "");
        }

    function UP_3(uint256 Skill_,address sender) public virtual override  {
        require(details.balanceOf(sender, Details_num1[Skill_]) >= SkillUP_Details1_3[Skill_] &&
        details.balanceOf(sender, Details_num2[Skill_]) >= SkillUP_Details2_3[Skill_] ,"not enough details");

        details.safeTransferFrom(sender, Contr.getStock(), Details_num1[Skill_], SkillUP_Details1_3[Skill_], "");
        details.safeTransferFrom(sender, Contr.getStock(), Details_num2[Skill_], SkillUP_Details2_3[Skill_], "");
        }

    function GNFTtrans(uint256 num_RepairKit,address sender) public virtual override {
        require(mINT_GNFT.balanceOf(sender, num_RepairKit) >=1,"");
        mINT_GNFT.safeTransferFrom(sender, Contr.getStock(), num_RepairKit, 1,"");
    }

     //Get_____________________________________________________________________

    function getOpening_Wear () public virtual override view returns(uint256){
       return Opening_Wear;
    }

    function GetWearPlus (uint256 numRK) public virtual override view returns (uint256 c) {
        if (numRK==9){
            return WearPlus[1];
        }
        else if (numRK == 19) {
            return WearPlus[2];
        }
         else if (numRK == 29) {
            return WearPlus[3];
        }
    }

    function getSkillUP_EX_1 (uint256 x) public virtual override view returns(uint256){
       return SkillUP_EX_1[x];
    }
    function getSkillUP_EX_2 (uint256 x) public virtual override view returns(uint256){
       return SkillUP_EX_2[x];
    }
    function getSkillUP_EX_3 (uint256 x) public virtual override view returns(uint256){
       return SkillUP_EX_3[x];
    }


    function getSkillUP_Wear_1 (uint256 x) public virtual override view returns(uint256){
       return SkillUP_Wear_1[x];
    }
    function getSkillUP_Wear_2 (uint256 x) public virtual override view returns(uint256){
       return SkillUP_Wear_2[x];
    }
    function getSkillUP_Wear_3 (uint256 x) public virtual override view returns(uint256){
       return SkillUP_Wear_3[x];
    }


    function getChestLevel (uint256 x) public virtual override view returns(uint256){
        return ChestLevel[x];
    }

    function GetSkillUP_Details(uint256 num_UP) public virtual override view returns( uint256 up1 ,uint256 up2){
        up1=SkillUP_Details1[num_UP];
        up2=SkillUP_Details2[num_UP];
    }

    function GetSkillUP_Details_2(uint256 num_UP) public virtual override view returns( uint256 up1 ,uint256 up2){
        up1=SkillUP_Details1_2[num_UP];
        up2=SkillUP_Details2_2[num_UP];
    }

    function GetSkillUP_Details_3(uint256 num_UP) public virtual override view returns( uint256 up1 ,uint256 up2){
        up1=SkillUP_Details1_3[num_UP];
        up2=SkillUP_Details2_3[num_UP];
    }

    //Set________________________________________________________________________________-

    function setSkillUP_num (uint256 up2_33,uint256 up2_34,
        uint256 up3_34,uint256 up3_35,uint256 up4_35,uint256 up4_36) external onlyOwner {
        SkillUP_Details1[1] = up2_33;
        SkillUP_Details1[2] = up3_34;
        SkillUP_Details1[3] = up4_35;

        SkillUP_Details2[1] = up2_34;
        SkillUP_Details2[2] = up3_35;
        SkillUP_Details2[3] = up4_36;
    } 

    function setSkillUP_num_2 (uint256 up2_33,uint256 up2_34,
        uint256 up3_34,uint256 up3_35,uint256 up4_35,uint256 up4_36) external onlyOwner {
        SkillUP_Details1_2[1] = up2_33;
        SkillUP_Details1_2[2] = up3_34;
        SkillUP_Details1_2[3] = up4_35;

        SkillUP_Details2_2[1] = up2_34;
        SkillUP_Details2_2[2] = up3_35;
        SkillUP_Details2_2[3] = up4_36;
    } 

    function setSkillUP_num_3 (uint256 up2_33,uint256 up2_34,
        uint256 up3_34,uint256 up3_35,uint256 up4_35,uint256 up4_36) external onlyOwner {
        SkillUP_Details1_3[1] = up2_33;
        SkillUP_Details1_3[2] = up3_34;
        SkillUP_Details1_3[3] = up4_35;

        SkillUP_Details2_3[1] = up2_34;
        SkillUP_Details2_3[2] = up3_35;
        SkillUP_Details2_3[3] = up4_36;
    } 

    function setSkillUP_EX_1 (uint256 _EX1,uint256 _EX2,uint256 _EX3) external onlyOwner {
        SkillUP_EX_1[1] = _EX1;
        SkillUP_EX_1[2] = _EX2;
        SkillUP_EX_1[3] = _EX3;
    }

    function setSkillUP_EX_2 (uint256 _EX1,uint256 _EX2,uint256 _EX3) external onlyOwner {
        SkillUP_EX_2[1] = _EX1;
        SkillUP_EX_2[2] = _EX2;
        SkillUP_EX_2[3] = _EX3;
    }

    function setSkillUP_EX_3 (uint256 _EX1,uint256 _EX2,uint256 _EX3) external onlyOwner {
        SkillUP_EX_3[1] = _EX1;
        SkillUP_EX_3[2] = _EX2;
        SkillUP_EX_3[3] = _EX3;
    }

    function setSkillUP_Wear_1 (uint256 _Wear1,uint256 _Wear2,uint256 _Wear3) external onlyOwner {
        SkillUP_Wear_1[1] = _Wear1;
        SkillUP_Wear_1[2] = _Wear2;
        SkillUP_Wear_1[3] = _Wear3;
    }

    function setSkillUP_Wear_2 (uint256 _Wear1,uint256 _Wear2,uint256 _Wear3) external onlyOwner {
        SkillUP_Wear_2[1] = _Wear1;
        SkillUP_Wear_2[2] = _Wear2;
        SkillUP_Wear_2[3] = _Wear3;
    }
    function setSkillUP_Wear_3 (uint256 _Wear1,uint256 _Wear2,uint256 _Wear3) external onlyOwner {
        SkillUP_Wear_3[1] = _Wear1;
        SkillUP_Wear_3[2] = _Wear2;
        SkillUP_Wear_3[3] = _Wear3;
    }

    function setChestLevel (uint256 num, uint256 ChestLevel_) external onlyOwner {
        ChestLevel[num] = ChestLevel_;
    }

    function setOpening_Wear (uint256 num) external onlyOwner {
    Opening_Wear = num;
    }

    function setWearPlus (uint256 num, uint256 WearPlus_) external onlyOwner {
        WearPlus[num] = WearPlus_;
    }

     function  update()  public virtual override{
        details = IERC1155(address(Contr.getDetails()));
        mINT_GNFT= IERC1155(address(Contr.getMINT_GNFT()));
  } 
    }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/*
████████╗██╗████████╗██╗███╗░░░███╗██╗████████╗██╗
╚══██╔══╝██║╚══██╔══╝██║████╗░████║██║╚══██╔══╝██║
░░░██║░░░██║░░░██║░░░██║██╔████╔██║██║░░░██║░░░██║
░░░██║░░░██║░░░██║░░░██║██║╚██╔╝██║██║░░░██║░░░██║
░░░██║░░░██║░░░██║░░░██║██║░╚═╝░██║██║░░░██║░░░██║
░░░╚═╝░░░╚═╝░░░╚═╝░░░╚═╝╚═╝░░░░░╚═╝╚═╝░░░╚═╝░░░╚═╝
*/

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./IDetails.sol";
import "./IBasic_info.sol";
import "./IContracts_TITIMITI.sol";

contract Details is ERC1155, Ownable, Pausable,IDetails {
    IContracts_TITIMITI Contr;
    IBasic_info Basic;
   
    string private URL;
    
    //GNFT clothes ----------------------------------------
    //Scoping and restrictions
    uint256[] private TotalSupply = [0,0,0,0];

    //GNFT clothes essence
    uint256 public constant Detail_1 = 30;
    uint256 public constant Detail_2 = 31;
    uint256 public constant Detail_3 = 32;
    uint256 public constant Detail_4 = 33;

    //колличество деталей для крафта 
    uint256[] public CraftDetail =[10,5,3]; //+
     
    constructor() ERC1155("https://gateway.pinata.cloud/ipfs/Qmaa6wX73LwNsJ5cLrAqVhQcyXmNpXRpivavJH27tnRkz1/") {
        Contr=IContracts_TITIMITI(0x998A99E482DFa7c436a39296B16C8d11e0beBFea);
         Basic=IBasic_info(address(Contr.getBasic_info()));
         update_URL();
    }

//MINT -----------------------------------///;)--------------------
    //0 Detail_1
    function mint_Detail_1(address adr,uint256 amount) public onlyOwner {
        _mint(adr,30,amount,"");
        uint256 n= TotalSupply[0];
        TotalSupply[0] = n + amount;
    }
    
    //1 Detail_2
    function mint_Detail_2(address adr,uint256 amount) public {
        address sender = msg.sender;
        require(balanceOf(sender,30) >= amount*CraftDetail[0]);
        safeTransferFrom(sender, Contr.getStock(),30, amount*CraftDetail[0], "");
        _mint(adr,31,amount,"");
        uint256 n= TotalSupply[1];
        TotalSupply[1] = n + amount;  
    }

    //2 Detail_3
    function mint_Detail_3(address adr,uint256 amount) public {
         address sender = msg.sender;
        require(balanceOf(sender,31) >= amount*CraftDetail[1]);
        safeTransferFrom(sender, Contr.getStock(),31, amount*CraftDetail[1], "");
        _mint(adr,32,amount,"");
        uint256 n= TotalSupply[2];
        TotalSupply[2] = n + amount;
    }

    //3 Detail_4
    function mint_Detail_4(address adr,uint256 amount) public {
         address sender = msg.sender;
        require(balanceOf(sender,32) >= amount*CraftDetail[2]);
        safeTransferFrom(sender, Contr.getStock(),32, amount*CraftDetail[2], "");
        _mint(adr,33,amount,"");
        uint256 n= TotalSupply[3];
        TotalSupply[3] = n + amount;
        
    }
    
    function _beforeTokenTransfer(address operator, address from, address to, 
    uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function TotalSupply_id (uint256 ID_Detail) public virtual override view returns (uint256 TotalSupply_) {
        return TotalSupply[ID_Detail-30];
    } 
    function Get_CraftDetail(uint256 ID_Detail) public virtual override view returns (uint256 CraftDetail__) {
        return CraftDetail[ID_Detail-30];
    } 

    function uri(uint256 _tokenId) override public view returns (string memory) {
        return string(
        abi.encodePacked( URL, Strings.toString(_tokenId),".json")
        );
    }

    function setCraft (uint256 numCraft, uint256 CraftDetail_) external onlyOwner {
        CraftDetail[numCraft]=CraftDetail_;
    }

    function update_URL()  public virtual override{
         _setURI(Basic.Get_URL());
         URL = Basic.Get_URL();
  } 

  function  update()  public virtual override{
        Contr=IContracts_TITIMITI(0x998A99E482DFa7c436a39296B16C8d11e0beBFea);
         Basic=IBasic_info(address(Contr.getBasic_info()));
  } 
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
/*
████████╗██╗████████╗██╗███╗░░░███╗██╗████████╗██╗
╚══██╔══╝██║╚══██╔══╝██║████╗░████║██║╚══██╔══╝██║
░░░██║░░░██║░░░██║░░░██║██╔████╔██║██║░░░██║░░░██║
░░░██║░░░██║░░░██║░░░██║██║╚██╔╝██║██║░░░██║░░░██║
░░░██║░░░██║░░░██║░░░██║██║░╚═╝░██║██║░░░██║░░░██║
░░░╚═╝░░░╚═╝░░░╚═╝░░░╚═╝╚═╝░░░░░╚═╝╚═╝░░░╚═╝░░░╚═╝
*/

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./IContracts_TITIMITI.sol";
import "./Idis.sol";
import "./IMINT.sol";
import "./IBasic_info.sol";

contract MINT_GNFT is ERC1155, Ownable, Pausable,IMINT {
    IContracts_TITIMITI Contr;
    IBasic_info Basic;
    Idis dis;
    string private URL;
    
    //GNFT clothes ----------------------------------------
    //Scoping and restrictions
    uint256[30] public TotalSupply_clothes = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    uint256[30] public MaxSupply_clothes = [30000,30000,30000,30000,30000,30000,30000,30000,60000,30000,
    15000,15000,15000,15000,15000,15000,15000,15000,30000,30000,
    50000,50000,50000,50000,50000,50000,50000,50000,10000,30000];

    //GNFT clothes essence
    uint256 public constant Jacket_1 = 0;
    uint256 public constant Pants_1 = 1;
    uint256 public constant Shoes_1 = 2;
    uint256 public constant Hat_1 = 3;
    uint256 public constant Glovers_1 = 4;
    uint256 public constant Glasses_1 = 5;
    uint256 public constant Bracelet_1 = 6;
    uint256 public constant Chain_1 = 7;
    uint256 public constant Radar_1 = 8;
    uint256 public constant RepairKit_1 = 9;

    uint256 public constant Jacket_2 = 10;
    uint256 public constant Pants_2 = 11;
    uint256 public constant Shoes_2 = 12;
    uint256 public constant Hat_2 = 13;
    uint256 public constant Glovers_2 = 14;
    uint256 public constant Glasses_2 = 15;
    uint256 public constant Bracelet_2 = 16;
    uint256 public constant Chain_2 = 17;
    uint256 public constant Radar_2 = 18;
    uint256 public constant RepairKit_2 = 19;

    uint256 public constant Jacket_3 = 20;
    uint256 public constant Pants_3 = 21;
    uint256 public constant Shoes_3 = 22;
    uint256 public constant Hat_3 = 23;
    uint256 public constant Glovers_3 = 24;
    uint256 public constant Glasses_3 = 25;
    uint256 public constant Bracelet_3 = 26;
    uint256 public constant Chain_3 = 27;
    uint256 public constant Radar_3 = 28;
    uint256 public constant RepairKit_3 = 29;
   
     
    constructor() ERC1155("") {
        Contr=IContracts_TITIMITI(0x998A99E482DFa7c436a39296B16C8d11e0beBFea);
         Basic=IBasic_info(address(Contr.getBasic_info()));
         dis=Idis(address(Contr.getdis()));
         update_URL();
    }

//MINT -----------------------------------///;)--------------------
    function mint(address adr,uint256 amount, uint256 numGNFT) public {
        address sender = msg.sender;
        require((TotalSupply_clothes[numGNFT]+amount) <= MaxSupply_clothes[numGNFT],"Maximum number reached");
        dis.MITItrans(sender, amount, numGNFT);
        uint256 n= TotalSupply_clothes[numGNFT];
        TotalSupply_clothes[numGNFT] = n + amount;
        _mint(adr,numGNFT,amount,"");
    }

    function _beforeTokenTransfer(address operator, address from, address to, 
    uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function getTotalSupply_clothes(uint256 ID_GNFT) public virtual override view returns (uint256 TotalSupply_clothes_) {
        return TotalSupply_clothes[ID_GNFT];
    }
    function get_MaxSupply_clothes(uint256 ID_GNFT) public virtual override view returns (uint256 MaxSupply_clothes_) {
        return MaxSupply_clothes[ID_GNFT];
    }

    function uri(uint256 _tokenId) override public view returns (string memory) {
        return string(
        abi.encodePacked( URL, Strings.toString(_tokenId),".json")
        );
    }
    
    function set_MaxSupply_clothes(uint256 ID_GNFT,uint256 NewMaxSupply) public onlyOwner {
        MaxSupply_clothes[ID_GNFT]=NewMaxSupply;
    }

    function update_URL()  public virtual override{
         _setURI(Basic.Get_URL());
         URL = Basic.Get_URL();
  } 

    function  update()  public virtual override{
         Basic=IBasic_info(address(Contr.getBasic_info()));
  } 
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IContracts_TITIMITI {
    function getZoomLoupe() external view returns (address);
    function getMining() external view returns (address);
    function getLandLord() external view returns (address);
    function getFundNFTA() external view returns (address);
    function getBurn() external view returns (address);
    function getStock() external view returns (address);
    function getTeam() external view returns (address);
    function getCashback() external view returns (address);
    function getRsearchers() external view returns (address);
    function getDev() external view returns (address);
    function getMiningPool() external view returns (address);
    function getTitifund() external view returns (address);
    function getMINT_GNFT() external view returns (address);
    function getMiticoin() external view returns (address);
    function getDetails() external view returns (address);
    function getdis() external view returns (address);
    function getBasic_info() external view returns (address);
    function getCollections() external view returns (address);
    function getNFTO() external view returns (address);
    function getNFTA() external view returns (address);
    function getSkillUP() external view returns (address);
    function getTake() external view returns (address);
    function getTrue_chest() external view returns (address);
    function getPrice() external view returns (address);
    function getInvest() external view returns (address);
    function getSaleMITI() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ISkill_c {
    function UP (uint256 Skill_,address sender) external;
    function UP_2(uint256 Skill_,address sender) external;
    function UP_3(uint256 Skill_,address sender) external;

    function getSkillUP_EX_1 (uint256 x) external view returns(uint256);
    function getSkillUP_EX_2 (uint256 x) external view returns(uint256);
    function getSkillUP_EX_3 (uint256 x) external view returns(uint256);

    function getSkillUP_Wear_1 (uint x) external view returns(uint256);
    function getSkillUP_Wear_2 (uint x) external view returns(uint256);
    function getSkillUP_Wear_3 (uint x) external view returns(uint256);

    function GNFTtrans(uint256 num_RepairKit,address sender) external;

    function GetWearPlus (uint256 numRK) external view returns (uint256 c);

    function getOpening_Wear () external view returns(uint256);

    function getChestLevel (uint x) external view returns(uint256);

    function GetSkillUP_Details(uint256 num_UP) external view returns( uint256 up1 ,uint256 up2);
    function GetSkillUP_Details_2(uint256 num_UP) external view returns( uint256 up1 ,uint256 up2);
    function GetSkillUP_Details_3(uint256 num_UP) external view returns( uint256 up1 ,uint256 up2);

    function  update() external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (security/Pausable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
abstract contract Pausable is Context {
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor() {
        _paused = false;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Throws if the contract is paused.
     */
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    /**
     * @dev Throws if the contract is not paused.
     */
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/IERC1155.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IBasic_info { 
    function GetCoordinate (uint256 ID)  external view  returns  (string memory x,string memory y);
    function Get_URL () external view  returns (string memory);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IDetails { 
    function TotalSupply_id (uint256 ID_Detail) external view returns (uint256 TotalSupply_);
    function Get_CraftDetail(uint256 ID_Detail) external view returns (uint256 CraftDetail__);
    function update_URL() external;
    function  update() external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC1155/ERC1155.sol)

pragma solidity ^0.8.0;

import "./IERC1155.sol";
import "./IERC1155Receiver.sol";
import "./extensions/IERC1155MetadataURI.sol";
import "../../utils/Address.sol";
import "../../utils/Context.sol";
import "../../utils/introspection/ERC165.sol";

/**
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using Address for address;

    // Mapping from token ID to account balances
    mapping(uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /**
     * @dev See {_setURI}.
     */
    constructor(string memory uri_) {
        _setURI(uri_);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) public view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: address zero is not a valid owner");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not token owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _afterTokenTransfer(operator, from, to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _afterTokenTransfer(operator, address(0), to, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `from`
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `from` must have at least `amount` tokens of token type `id`.
     */
    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();
        uint256[] memory ids = _asSingletonArray(id);
        uint256[] memory amounts = _asSingletonArray(amount);

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);

        _afterTokenTransfer(operator, from, address(0), ids, amounts, "");
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Emits an {ApprovalForAll} event.
     */
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `ids` and `amounts` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC1155/IERC1155Receiver.sol)

pragma solidity ^0.8.0;

import "../../utils/introspection/IERC165.sol";

/**
 * @dev _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @dev Handles the receipt of a single ERC1155 token type. This function is
     * called at the end of a `safeTransferFrom` after the balance has been updated.
     *
     * NOTE: To accept the transfer, this must return
     * `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
     * (i.e. 0xf23a6e61, or its own function selector).
     *
     * @param operator The address which initiated the transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param id The ID of the token being transferred
     * @param value The amount of tokens being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @dev Handles the receipt of a multiple ERC1155 token types. This function
     * is called at the end of a `safeBatchTransferFrom` after the balances have
     * been updated.
     *
     * NOTE: To accept the transfer(s), this must return
     * `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
     * (i.e. 0xbc197c81, or its own function selector).
     *
     * @param operator The address which initiated the batch transfer (i.e. msg.sender)
     * @param from The address which previously owned the token
     * @param ids An array containing ids of each token being transferred (order and length must match values array)
     * @param values An array containing amounts of each token being transferred (order and length must match ids array)
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly
                /// @solidity memory-safe-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC1155/extensions/IERC1155MetadataURI.sol)

pragma solidity ^0.8.0;

import "../IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface Idis{
     function MITItrans(address adr,uint256 amount,uint256 numGNFT) external;

    function getZoomLoupe() external view returns (address);

    function getMining() external view returns (address);

    function getLandLord() external view returns (address);

    function getNFTA() external view returns (address);

    function getBurn() external view returns (address);

    function getStock() external view returns (address);

    function get_percent_ZoomLoupe () external view returns (uint256);
    function get_percent_Mining () external view returns (uint256);
    function get_percent_LandLord () external view returns (uint256);
    function get_percent_NFTA () external view returns (uint256);
    function get_percent_Burn () external view returns (uint256);

    function  update()  external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IMINT {
    function getTotalSupply_clothes(uint256 idgnft) external view returns (uint256 TotalSupply_clothes_);
    function get_MaxSupply_clothes(uint256 ID_GNFT) external view returns (uint256 MaxSupply_clothes_);
    function update_URL() external;
    function update() external;
}