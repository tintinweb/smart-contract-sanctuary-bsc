pragma solidity >= 0.5.17;

import "./math.sol";
import "./IERC20.sol";

library useDecimal{
    using uintTool for uint;

    function m278(uint n) internal pure returns(uint){
        return n.mul(278)/1000;
    }
}

library Address {
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
}

contract MTCPFPSale is math{
    using Address for address;

    function() external payable{}
	address manager;
	address _MTCAddr = 0x5F1D2cfDEB097B83eD2f35Cf3E827DE2b700F05a;
    address _treasury;
	uint AngelSalePrice = 2000; //1BNB = 2000MTC | 1MTC = 0.0005BNB
	uint AngelSaleAmount = 0;
	uint addAngelQuota = 700 * 10 ** uint(18);
	uint MaxAngelSaleAmount = 8000000 * 10 ** uint(18);
	uint WhitelistLength;
	uint WhitelistQuota;
	
	uint256 public ClosingTime = 1646063999; //Closing at Mon Feb 28 2022 23:59:59 UTC+0800.
	
    struct WhitelistInfo {
        uint _AngelQuota;
        uint _buyAmount;
    }
	
    mapping(address => WhitelistInfo) public whitelistInfos;

    event AngelSaleMTC(uint _amountsIn, uint _amountsOut, bool result);
	
    constructor() public {
        manager = msg.sender;
    }

    modifier onlyManager{
        require(msg.sender == manager, "Not manager");
        _;
    }

    function changeManager(address _new_manager) public {
        require(msg.sender == manager, "Not superManager");
        manager = _new_manager;
    }

    function withdraw() external onlyManager{
        (msg.sender).transfer(address(this).balance);
    }

    function withdrawTokens(address tokenAddr) external onlyManager{
        uint _thisTokenBalance = IERC20(tokenAddr).balanceOf(address(this));
        require(IERC20(tokenAddr).transfer(msg.sender, _thisTokenBalance));
    }

    //----------------Whitelist address----------------------------
	
    function addWhitelistBatch(address[] memory _wAddrs) public onlyManager returns (bool) {
        uint _addressAmount = _wAddrs.length;
        for (uint i = 0; i < _addressAmount; i++){
			addWhitelist(_wAddrs[i]);
        }
        return true;
    }

    function addWhitelistManager(address _wAddrs) external onlyManager {
        require(_wAddrs != address(0), "MTC Angel Sale : token is the zero address");
            addWhitelist(_wAddrs);
    }

    function addWhitelist(address _wAddrs) internal returns(bool) {
		WhitelistLength = WhitelistLength.add(1);
        whitelistInfos[_wAddrs]._AngelQuota = whitelistInfos[_wAddrs]._AngelQuota.add(addAngelQuota);
		WhitelistQuota = WhitelistQuota.add(addAngelQuota);
        return true;
    }

    function getWhitelistLength() public view returns (uint256) {
        return WhitelistLength;
    }

    function isWhitelist(address _Addrs) public view returns (bool) {
        bool _isWhitelist = true;
		if(whitelistInfos[_Addrs]._AngelQuota == 0){
            _isWhitelist = false;
		}
        return _isWhitelist;
    }

    //---------------------------------------------------------------------------------
	
    function isClosed() public view returns (bool) {
        return now >= ClosingTime;
    }

	function MTCAddr() public view returns(address){
        require(_MTCAddr != address(0), "It's a null address");
        return _MTCAddr;
    }

	function Treasury() public view returns(address){
        require(_treasury != address(0), "It's a null address");
        return _treasury;
    }
	
	function setTreasury(address addr) public onlyManager{
        _treasury = addr;
    }
	
	function getAngelSalePrice() public view returns (uint256) {
        return AngelSalePrice;
    }

	function getAngelSaleAmount() public view returns (uint256) {
        return AngelSaleAmount;
    }

	function getMaxAngelSaleAmount() public view returns (uint256) {
        return MaxAngelSaleAmount;
    }

	function getListbuyAmount(address inputAddr) public view returns (uint256) {
        return whitelistInfos[inputAddr]._buyAmount;
    }
	
	function getAngelQuota(address inputAddr) public view returns (uint256) {
        return whitelistInfos[inputAddr]._AngelQuota;
    }

	//--Swap Exact BNB to MTC AngelSale--//
    function AngelSale() external payable{
		require(isWhitelist(msg.sender), "MTC Angel Sale : This address is not in Whitelist.");
		require(!isClosed(), "MTC Angel Sale : Angel sale closed.");
		uint _tradeAmount = msg.value;
		uint256 _tokenAmountsOut = _tradeAmount.mul(AngelSalePrice);
		
		require(AngelSaleAmount.add(_tokenAmountsOut) <= MaxAngelSaleAmount, "MTC Angel Sale : Sold out.");
		require(whitelistInfos[msg.sender]._buyAmount.add(_tokenAmountsOut) <= whitelistInfos[msg.sender]._AngelQuota, "MTC Angel Sale : MTC amounts error.");

		require(IERC20(MTCAddr()).transfer(msg.sender, _tokenAmountsOut));
		AngelSaleAmount = AngelSaleAmount.add(_tokenAmountsOut);
		Treasury().toPayable().transfer(_tradeAmount);
		whitelistInfos[msg.sender]._buyAmount = whitelistInfos[msg.sender]._buyAmount.add(_tokenAmountsOut);
		emit AngelSaleMTC(_tradeAmount, _tokenAmountsOut, true);
    }

	function destroy() external onlyManager{ 
        selfdestruct(msg.sender); 
	}
}