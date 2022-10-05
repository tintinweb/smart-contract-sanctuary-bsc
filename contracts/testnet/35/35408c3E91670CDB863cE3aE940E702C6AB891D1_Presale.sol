/**
 *Submitted for verification at BscScan.com on 2022-10-05
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IBEP20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}

contract Presale is Context  {
    IBEP20 public TIME;
    IBEP20 public BTC;
    IBEP20 public ETH;
    IBEP20 public BNB;
    IBEP20 public CAKE;
    IBEP20 public USDT;
    IBEP20 public BUSD;
    address private owner;
    address private presalewallet; //0x4503412Ffd1862bB75f76fDD0f993f6f11780B92
    uint256 private ratio;
    uint256 decimals=10**18 ;
    mapping (address => mapping (address => uint256)) private _allowances; 
    //20000000000000000000000000000
        
    constructor()
    {
        owner = msg.sender;
        TIME = IBEP20(0x2571963cFC9DF3136e5bCd5633c67AE950d8D726); 
        BTC = IBEP20(0x6ce8dA28E2f864420840cF74474eFf5fD80E65B8) ;
        ETH =  IBEP20(0xd66c6B4F0be8CE5b39D52E0Fd1344c389929B378) ; 
        BNB= IBEP20(0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd) ;
        CAKE= IBEP20(0xFa60D973F7642B748046464e165A65B7323b0DEE) ;
        USDT = IBEP20(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd);
        BUSD = IBEP20(0x8516Fc284AEEaa0374E66037BD2309349FF728eA); 
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    function Owner() public view returns (address) {
        return owner;
    }

    function setpresalewallet(address newpreaslewallet) public onlyOwner{
        presalewallet = newpreaslewallet;
    }
    
//swap
    function _safeTransferFrom(IBEP20 token,address sender,address recipient,uint amount) private {
        bool sent = token.transferFrom(sender, recipient, amount);
        require(sent, "Token transfer failed");
    }

    function SwapBTC(uint256 amount) public  {
        require(
            BTC.allowance(_msgSender(), address(this)) >= amount,
            "BTC allowance too low"
        );
        require(
            TIME.allowance(presalewallet, address(this)) >= amount*CurrentUSDRatio(),
            "TIME allowance too low"
        );
        require(
            AllownceTIME() > 0,
            "Presale haven't start "
        );

        //swap
        _safeTransferFrom(BTC, _msgSender(), presalewallet, amount);
        _safeTransferFrom(TIME, presalewallet, _msgSender(), amount*CurrentBTCRatio());
    }

     function SwapETH(uint256 amount) public  {
        require(
            ETH.allowance(_msgSender(), address(this)) >= amount,
            "ETH allowance too low"
        );
        require(
            TIME.allowance(presalewallet, address(this)) >= amount*CurrentUSDRatio(),
            "TIME allowance too low"
        );
        require(
            AllownceTIME() > 0,
            "Presale haven't start "
        );

        //swap
        _safeTransferFrom(ETH, _msgSender(), presalewallet, amount);
        _safeTransferFrom(TIME, presalewallet, _msgSender(), amount*CurrentETHRatio());
    }

    function SwapBNB(uint256 amount) public  {
        
        require(
            BNB.allowance(_msgSender(), address(this)) >= amount,
            "BNB allowance too low"
        );
        require(
            TIME.allowance(presalewallet, address(this)) >= amount*CurrentBNBRatio(),
            "TIME allowance too low"
        );
        require(
            AllownceTIME() > 0,
            "Presale haven't start "
        );

        //swap
        _safeTransferFrom(BNB, _msgSender(), presalewallet, amount);
        _safeTransferFrom(TIME, presalewallet, _msgSender(), amount*CurrentBNBRatio());
    }

    function SwapCAKE(uint256 amount) public  {
        
        require(
            CAKE.allowance(_msgSender(), address(this)) >= amount,
            "CAKE allowance too low"
        );
        require(
            TIME.allowance(presalewallet, address(this)) >= amount*CurrentCAKERatio(),
            "TIME allowance too low"
        );
        require(
            AllownceTIME() > 0,
            "Presale haven't start "
        );

        //swap
        _safeTransferFrom(CAKE, _msgSender(), presalewallet, amount);
        _safeTransferFrom(TIME, presalewallet, _msgSender(), amount*CurrentCAKERatio());
    }

    function SwapUSDT(uint256 amount) public  {
        require(
            USDT.allowance(_msgSender(), address(this)) >= amount,
            "USDT allowance too low"
        );
        require(
            TIME.allowance(presalewallet, address(this)) >= amount*CurrentUSDRatio(),
            "TIME allowance too low"
        );
        require(
            AllownceTIME() > 0,
            "Presale haven't start "
        );

        //swap
        _safeTransferFrom(USDT, _msgSender(), presalewallet, amount);
        _safeTransferFrom(TIME, presalewallet, _msgSender(), amount*CurrentUSDRatio());
    }

    function SwapBUSD(uint256 amount) public  {
        require(
            BUSD.allowance(_msgSender(), address(this)) >= amount,
            "BUSD allowance too low"
        );
        require(
            TIME.allowance(presalewallet, address(this)) >= amount*CurrentUSDRatio(),
            "TIME allowance too low"
        );
        require(
            AllownceTIME() > 0,
            "Presale haven't start "
        );

        //swap
        _safeTransferFrom(BUSD, _msgSender(), presalewallet, amount);
        _safeTransferFrom(TIME, presalewallet, _msgSender(), amount*CurrentUSDRatio());
    }


//ratio  
    function CurrentBTCRatio() public view  returns (uint256 btcratioo){
            uint256 btcratio=18000*25000;
            require(
            AllownceTIME() > 0,
            "Presale haven't start "
            ); 
            if (0<AllownceTIME() && AllownceTIME()<5000000000*decimals) btcratioo = btcratio*80/100 ; 
                else if (5000000000<AllownceTIME() && AllownceTIME()<10000000000*decimals) btcratioo = btcratio*90/100 ; 
                    else if (10000000000<AllownceTIME() && AllownceTIME()<15000000000*decimals) btcratioo = btcratio*95/100 ;  
                        else btcratioo = btcratio ; 
        return btcratioo ;
    }

    function CurrentETHRatio() public view  returns (uint256 ethratioo){
            
            uint256 ethratio=1000*25000;
            require(
            AllownceTIME() > 0,
            "Presale haven't start "
            ); 
            if (0<AllownceTIME() && AllownceTIME()<5000000000*decimals) ethratioo = ethratio*80/100 ; 
                else if (5000000000<AllownceTIME() && AllownceTIME()<10000000000*decimals) ethratioo = ethratio*90/100 ; 
                    else if (10000000000<AllownceTIME() && AllownceTIME()<15000000000*decimals) ethratioo = ethratio*95/100 ;  
                        else ethratioo = ethratio ; 
        return ethratioo ;
    }

    function CurrentBNBRatio() public view  returns (uint256 bnbratioo){
            
            uint256 bnbratio=250*25000;
            require(
            TIME.balanceOf(presalewallet) > 0,
            "Presale haven't start "
            ); 
            if (0<AllownceTIME() && AllownceTIME()<5000000000*decimals) bnbratioo = bnbratio*80/100 ;  
                else if (5000000000<AllownceTIME() && AllownceTIME()<10000000000*decimals) bnbratioo = bnbratio*90/100 ; 
                    else if (10000000000<AllownceTIME() && AllownceTIME()<15000000000*decimals) bnbratioo = bnbratio*95/100 ;  
                        else bnbratioo = bnbratio ; 
        return bnbratioo ;
    }

    function CurrentCAKERatio() public view  returns (uint256 cakeratioo){
            uint256 cakeratio=4*25000;
            require(
            TIME.balanceOf(presalewallet) > 0,
            "Presale haven't start "
            ); 
            if (0<AllownceTIME() && AllownceTIME()<5000000000*decimals) cakeratioo = cakeratio*80/100 ; 
                else if (5000000000<AllownceTIME() && AllownceTIME()<10000000000*decimals) cakeratioo = cakeratio*90/100 ; 
                    else if (10000000000<AllownceTIME() && AllownceTIME()<15000000000*decimals) cakeratioo = cakeratio*95/100; 
                        else cakeratioo = cakeratio ; 
        return cakeratioo ;
    }

    function CurrentUSDRatio() public view  returns (uint256 usdratioo){
            
            uint256 usdratio=1*25000;
            require(
            AllownceTIME() > 0,
            "Presale haven't start "
            ); 
            if (0<AllownceTIME() && AllownceTIME()<5000000000*decimals) usdratioo = usdratio*80/100 ; 
                else if (5000000000<AllownceTIME() && AllownceTIME()<10000000000*decimals) usdratioo = usdratio*90/100 ; 
                    else if (10000000000<AllownceTIME() && AllownceTIME()<15000000000*decimals) usdratioo = usdratio*95/100 ;  
                        else usdratioo = usdratio ; 
        return usdratioo ;
    }

    function presalewallett() public view  returns (address){
        return presalewallet ;
    }

//balance
    function BalanceTIME() public view  returns (uint256){
        return TIME.balanceOf(_msgSender()) ;
    }

    function BalanceBTC() public view  returns (uint256){
        return BTC.balanceOf(_msgSender()) ;
    }

        function BalanceETH() public view  returns (uint256){
        return ETH.balanceOf(_msgSender()) ;
    }

        function BalanceBNB() public view  returns (uint256){
        return BNB.balanceOf(_msgSender()) ;
    }

        function BalanceCAKE() public view  returns (uint256){
        return CAKE.balanceOf(_msgSender()) ;
    }

        function BalanceBUSD() public view  returns (uint256){
        return BUSD.balanceOf(_msgSender()) ;
    }

        function BalanceUSDT() public view  returns (uint256){
        return USDT.balanceOf(_msgSender()) ;
    }

//allow
    function AllownceTIME() public view  returns (uint256){
        return TIME.allowance(presalewallet, address(this)) ;
    }

    function AllownceBTC() public view  returns (uint256){
        return CAKE.allowance(_msgSender(), address(this)) ;
    }

    function AllownceETH() public view  returns (uint256){
        return CAKE.allowance(_msgSender(), address(this)) ;
    }

    function AllownceBNB() public view  returns (uint256){
        return BNB.allowance(_msgSender(), address(this)) ;
    }

    function AllownceCAKE() public view  returns (uint256){
        return CAKE.allowance(_msgSender(), address(this)) ;
    }

    function AllownceUSDT() public view  returns (uint256){
        return USDT.allowance(_msgSender(), address(this)) ;
    }

    function AllownceBUSD() public view  returns (uint256){
        return BUSD.allowance(_msgSender(), address(this)) ;
    }

}