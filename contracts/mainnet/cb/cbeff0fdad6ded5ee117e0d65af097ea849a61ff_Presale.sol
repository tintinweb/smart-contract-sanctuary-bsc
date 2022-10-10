/**
 *Submitted for verification at BscScan.com on 2022-10-10
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
        TIME = IBEP20(0x77e443932A780a825e10C547454F034982523b4C); 
        BTC = IBEP20(0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c) ;
        ETH =  IBEP20(0x2170Ed0880ac9A755fd29B2688956BD959F933F8) ; 
        BNB= IBEP20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c) ;
        CAKE= IBEP20(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82) ;
        USDT = IBEP20(0x55d398326f99059fF775485246999027B3197955);
        BUSD = IBEP20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56); 
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
            
            uint256 ethratio=1200*25000;
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
    function BalanceTIME(address account) public view  returns (uint256){
        return TIME.balanceOf(account) ;
    }

    function BalanceBTC(address account) public view  returns (uint256){
        return BTC.balanceOf(account) ;
    }

        function BalanceETH(address account) public view  returns (uint256){
        return ETH.balanceOf(account) ;
    }

        function BalanceBNB(address account) public view  returns (uint256){
        return BNB.balanceOf(account) ;
    }

        function BalanceCAKE(address account) public view  returns (uint256){
        return CAKE.balanceOf(account) ;
    }

        function BalanceBUSD(address account) public view  returns (uint256){
        return BUSD.balanceOf(account) ;
    }

        function BalanceUSDT(address account) public view  returns (uint256){
        return USDT.balanceOf(account) ;
    }

//allow
    function AllownceTIME() public view  returns (uint256){
        return TIME.allowance(presalewallet, address(this)) ;
    }

    function AllownceBTC(address account) public view  returns (uint256){
        return BTC.allowance(account, address(this)) ;
    }

    function AllownceETH(address account) public view  returns (uint256){
        return ETH.allowance(account, address(this)) ;
    }

    function AllownceBNB(address account) public view  returns (uint256){
        return BNB.allowance(account, address(this)) ;
    }

    function AllownceCAKE(address account) public view  returns (uint256){
        return CAKE.allowance(account, address(this)) ;
    }

    function AllownceUSDT(address account) public view  returns (uint256){
        return USDT.allowance(account, address(this)) ;
    }

    function AllownceBUSD(address account) public view  returns (uint256){
        return BUSD.allowance(account, address(this)) ;
    }

}