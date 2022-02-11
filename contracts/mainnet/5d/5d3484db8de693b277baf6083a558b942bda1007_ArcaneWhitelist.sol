/**
 *Submitted for verification at BscScan.com on 2022-02-08
*/

pragma solidity ^0.8.7;


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

contract ArcaneWhitelist {

    address public owner;
    // Token que será vendido
    IERC20 public token;
    // Endereço para onde os fundos irão
    address public wallet;

    // Quantas unidades de token é comprado por 1 wei
    // rate = 2. a cada 1 WEI o cliente ganha 2 TOKENS. E ASSIM VAI.
    
    uint256 public rate;
    // Amount of wei raised
    uint256 public weiRaised;

    // Reentrancy variable
    bool private isBuying;

    // Crowdsale is running
    bool public isRunning;

    //
    mapping( address => uint256 ) public purchaseByAddress;
    uint256 public maxBNBPurchaseByAddressPermitted = 100 ** 19; // 100BNB?

    

    event TokenPurchase(
        address indexed purchaser,
        address indexed beneficiary,
        uint256 value,
        uint256 amount
    );

    /**
    * ARCANE CARDS - Powered by Coxinha.IO
    * @param _owner Quem pode iniciar e parar o PreSale
    * @param _rate Numero de tokens por WEI
    * @param _wallet Endereço para cair os fundos
    * @param _token Endereço do token Arcane Cards
    */

    constructor(address _owner, uint256 _rate, address _wallet, IERC20 _token) {
        require(_rate > 0);
        require(_wallet != address(0));
        require(address(_token) != address(0));
        require(_owner != address(0));

        owner = _owner;
        rate = _rate;
        wallet = _wallet;
        token = _token;
    }

    fallback() external payable {
        buyTokens(msg.sender);
    }

    receive() external payable {
        buyTokens(msg.sender);
    }


    function checkBalance() public view returns(uint256){
        return IERC20(token).balanceOf(address(this));
    }

    
    /* Modifier Guard - Reentrancy */
    modifier Guard {
        require(!isBuying,"ARCANE FAILED: REETRANCY");
        isBuying = true;
        _;
        isBuying = false;
    }

    /* Modifier Running */
    modifier Running {
        require(isRunning,"ARCANE FAILED: PRESALE IS NOT RUNNING");
        _;
    }

    // LEGACY */
    // function verifyUserIsWhiteList(address _whitelistedAddress) public view returns(bool) {
    //   bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
    //   return userIsWhitelisted;
    // }

    function returnTokens() external {
      require(owner == msg.sender);
      require(isRunning == false,'IS RUNNING');
      
      IERC20(token).transfer(owner, checkBalance());
    }


    function buyTokens(address _beneficiary) public payable Guard Running   {
        require(msg.value < 2 ether );
        require(msg.value > 0.01 ether);
        //
        uint256 weiAmount = msg.value;
        //
        _preValidatePurchase(_beneficiary, weiAmount);
        //
        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount);
        //
        weiRaised = weiRaised + weiAmount;
        //
        _processPurchase(_beneficiary, tokens);
        //
        emit TokenPurchase( msg.sender, _beneficiary, weiAmount, tokens);
        //
        _updatePurchasingState(_beneficiary, weiAmount);
        //
        _forwardFunds();
    }


    // -----------------------------------------
    // External interface for Admin (Diego)
    // -----------------------------------------

    function setIsRunning(bool _running) external {
        require(msg.sender == owner,"ARCANE FAILED : SENDER IS NOT THE OWNER");
        isRunning = _running;
    }

    function changeOwner(address _dst) external {
        require(msg.sender == owner,"ARCANE FAILED : SENDER IS NOT THE OWNER");
        owner = _dst;
    }

    //

    // INTERNALS


    function _preValidatePurchase( address _beneficiary, uint256 _weiAmount ) internal pure {
        require(_beneficiary != address(0));
        require(_weiAmount != 0);
    }

    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        
        return (_weiAmount * rate ) / (10 ** 9);
    }

    function _processPurchase( address _beneficiary, uint256 _tokenAmount ) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
    }

    function _deliverTokens( address _beneficiary, uint256 _tokenAmount ) internal {
        token.transfer(_beneficiary, _tokenAmount);
    }

    function _updatePurchasingState( address _beneficiary, uint256 _weiAmount ) internal {
      purchaseByAddress[_beneficiary] += _weiAmount;
      require(maxBNBPurchaseByAddressPermitted >= purchaseByAddress[_beneficiary],"ARCANE FAILED: ( 100BNB ) MAX PURCHASED BY ADDRESS REACHED");
    }

    function _forwardFunds() internal {
       (bool success,) = payable(wallet).call{value: msg.value}("");
        require(success,"ARCANE FAILED : FORWARD FUNDS FAIL");
    }



}