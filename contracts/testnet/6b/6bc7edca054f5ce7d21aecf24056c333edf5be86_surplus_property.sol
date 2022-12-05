/**
 *Submitted for verification at BscScan.com on 2022-12-04
*/

//date 2022/12/04 Shiang Yu
pragma solidity ^0.5.0;                                  

interface IERC20 {//繼承token 的 balanceOf & transfer的功能
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);

}
contract wallet{
    IERC20 token = IERC20(address(0x788ECe004c452179127760E8814eafa985961F86));//繼承代幣地址
    address public motherContract;
    address public wallet_owner;
    address public careCenter=address(0);
    uint256 public careCenterMonthlyCharge=0;
    address[] public family;
    uint256[] public proportion;
    constructor(address _wallet_owner)public
    {
        wallet_owner=_wallet_owner;
        motherContract=msg.sender;
    }
    function withdraw_wallet(uint256 value)public
    {
        require(msg.sender==motherContract,"要由母合約傳送");
        token.transfer(wallet_owner,value);
    }
    function CareCenterPayment(address _careCenter,uint256 monthlyCharge)public
    {
        require(msg.sender==motherContract,"要由母合約傳送");
        careCenter=_careCenter;
        careCenterMonthlyCharge=monthlyCharge;
    }
    function pay()public returns(bool success)
    {
        require(msg.sender==motherContract,"要由母合約傳送");
        token.transfer(careCenter,careCenterMonthlyCharge);
        return true;
    }
    function setHeritage(address[] memory _family,uint256[] memory _proportion)public//比例為% ex. 因此proportion總和為100
    {
        require(msg.sender==motherContract,"要由母合約傳送");
        family=_family;
        proportion=_proportion;
    }
    function dead()public returns(bool success)
    {
        require(msg.sender==motherContract,"要由母合約傳送");
        uint256 totalMoney=token.balanceOf(address(this));
        for(uint i=0 ;i<proportion.length;i++)
        {
            token.transfer(family[i],totalMoney/100*proportion[i]);
        }
        return true;
    }
}
contract surplus_property{
    IERC20 token = IERC20(address(0x788ECe004c452179127760E8814eafa985961F86));//繼承代幣地址
    address public regulatoryAuthority;
    mapping (address => wallet) private walletByAddress;
    constructor()public
    {
        regulatoryAuthority=0x2489a0B967213785B575EE541D9d4F01464147D0;
    }
    function createWallet()public returns(bool success)
    {
        require(address(walletByAddress[msg.sender])==address(0),"已有用戶錢包");
        walletByAddress[msg.sender]=new wallet(msg.sender);
        return true;
    }
    function getWalletPorperty()public view returns(uint256 property)
    {
        require(address(walletByAddress[msg.sender])!=address(0),"無此用戶錢包");
        return token.balanceOf(address(walletByAddress[msg.sender]));
    }
    function withdraw_wallet(uint256 value)public returns(bool success)//要測試
    {
        require(address(walletByAddress[msg.sender])!=address(0),"無此用戶錢包");
        require(token.balanceOf(address(walletByAddress[msg.sender])) >= value,"金額不夠");
        walletByAddress[msg.sender].withdraw_wallet(value);
        return true;
    }
    function CareCenterPayment(address careCenter,uint256 monthlyCharge)public returns(bool success)
    {
        require(address(walletByAddress[msg.sender])!=address(0),"無此用戶錢包");
        //require(careCenter[careCenterName]!=address(0),"無此照顧中心")
        walletByAddress[msg.sender].CareCenterPayment(careCenter,monthlyCharge);
        return true;
    }
    function regulatoryAuthorityMonthlyCheck(bool confirmation, address elder)public returns(bool success)
    {
        require(msg.sender==regulatoryAuthority);
        require(address(walletByAddress[elder])!=address(0),"無此用戶錢包");
        if(confirmation==true)
        {
            return walletByAddress[elder].pay();
        }
    }
    function setHeritage(address[] memory _family,uint256[] memory _proportion)public returns(bool success)
    {
        require(address(walletByAddress[msg.sender])!=address(0),"無此用戶錢包");
        walletByAddress[msg.sender].setHeritage(_family,_proportion);
        return true;
    }
    function regulatoryAuthorityConfirmDead(address elder)public returns(bool success)
    {
        require(msg.sender==regulatoryAuthority);
        require(address(walletByAddress[elder])!=address(0),"無此用戶錢包");
        return walletByAddress[elder].dead();
    }
}