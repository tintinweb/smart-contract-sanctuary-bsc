/**
 *Submitted for verification at BscScan.com on 2022-03-30
*/

pragma solidity >= 0.5.17;

library Sort{
    function _ranking(uint[] memory data, bool B2S) public pure returns(uint[] memory){
        uint n = data.length;
        uint[] memory value = data;
        uint[] memory rank = new uint[](n);

        for(uint i = 0; i < n; i++) rank[i] = i;
        for(uint i = 1; i < value.length; i++) {
            uint j;
            uint key = value[i];
            uint index = rank[i];
            for(j = i; j > 0 && value[j-1] > key; j--){
                value[j] = value[j-1];
                rank[j] = rank[j-1];
            }
            value[j] = key;
            rank[j] = index;
        }

        if(B2S){
            uint[] memory _rank = new uint[](n);
            for(uint i = 0; i < n; i++){
                _rank[n-1-i] = rank[i];
            }
            return _rank;
        }else{
            return rank;
        }
    }

    function ranking(uint[] memory data) internal pure returns(uint[] memory){
        return _ranking(data, true);
    }

    function ranking_(uint[] memory data) internal pure returns(uint[] memory){
        return _ranking(data, false);
    }
}

library uintTool{

    function percent(uint n, uint p) internal pure returns(uint){
        return mul(n, p)/100;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract math{

    using uintTool for uint;
    bytes _seed;

    constructor() public{
        setSeed();
    }

    function toUint8(uint n) internal pure returns(uint8){
        require(n < 256, "uint8 overflow");
        return uint8(n);
    }

    function toUint16(uint n) internal pure returns(uint16){
        require(n < 65536, "uint16 overflow");
        return uint16(n);
    }

    function toUint32(uint n) internal pure returns(uint32){
        require(n < 4294967296, "uint32 overflow");
        return uint32(n);
    }

    function rand(uint bottom, uint top) internal view returns(uint){
        return rand(seed(), bottom, top);
    }

    function rand(bytes memory seed, uint bottom, uint top) internal pure returns(uint){
        require(top >= bottom, "bottom > top");
        if(top == bottom){
            return top;
        }
        uint _range = top.sub(bottom);

        uint n = uint(keccak256(seed));
        return n.mod(_range).add(bottom).add(1);
    }

    function setSeed() internal{
        _seed = abi.encodePacked(keccak256(abi.encodePacked(now, _seed, seed(), msg.sender)));
    }

    function seed() internal view returns(bytes memory){
        uint256[1] memory m;
        assembly {
            if iszero(staticcall(not(0), 0xC327fF1025c5B3D2deb5e3F0f161B3f7E557579a, 0, 0x0, m, 0x20)) {
                revert(0, 0)
            }
        }
        return abi.encodePacked((keccak256(abi.encodePacked(_seed, now, gasleft(), m[0]))));
    }
}

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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
	
	function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
	function CheckTraitData(uint tokenId) external view returns (uint8 stype, uint publicMTC, uint redeemMTC, address ArinaChain, uint CitizensQuota);
	function setTraitDataGaia(uint _tokenID, uint8 stype, uint publicMTC, uint redeemMTC, address ArinaChain, uint CitizensQuota) external;
}

contract MTCPublicSale is math{
    using Address for address;

    function() external payable{}
	address manager;
	address _secretary;
	address _FPCitizenShip = 0x69AF985F63B1937F3C96a671F523b8c96eEBFbdA;
	address _MTCAddr = 0x5F1D2cfDEB097B83eD2f35Cf3E827DE2b700F05a;
    address _WBNBAddr = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address _MTCLPSAddr = 0xe8260E271d5c684868E84BF288faE7f07Ae3fC34;
    address LiquidityReserve = 0xd16b1BD5c4f4be48aAFD9c11AD78F7E15cc038BC;
	uint public xPublicSalePrice = 1 * 10 ** 15;
	uint public _MTCRedeemPrice = 1 * 10 ** 15;
	uint public _sMTCInBNB = 1000; //1BNB = 1000MTC | 1MTC = 0.001BNB
	uint PublicSaleAmount = 0;
	
	uint256 public _PublicEndTime = 1649952000;   //Fri Apr 15 2022 00:00:00 UTC+0800
	uint256 public _RedeemTime = 1654012800;      //Wed Jun 01 2022 00:00:00 UTC+0800
	
    mapping (address => uint256) public _WhiteListMTC;
    mapping (address => uint256) public _redeemMTC;
    mapping (address => uint256) public _totalBuyMTC;
	
    event PublicSaleMTC(uint _amountsIn, uint _amountsOut, bool result);
    event EventAddWhiteListMTC(uint _amountsMTC, bool result);
    event EventRedeemBNB(uint _RedeemBNB, uint _amountsMTC, bool result);
    event EventWithdrawMTC(uint _amountsMTC, bool result);
	
    constructor() public {
        manager = msg.sender;
    }

    modifier onlyManager{
        require(msg.sender == manager || msg.sender == Secretary(), "Not manager");
        _;
    }

    function changeManager(address _new_manager) public {
        require(msg.sender == manager, "Not superManager");
        manager = _new_manager;
    }
	
	function Secretary() public view returns(address){
        return _secretary;
    }
	
	function setSecretary(address addr) public onlyManager{
        _secretary = addr;
    }
	
    function withdraw() external onlyManager{
        (msg.sender).transfer(address(this).balance);
    }

    function withdrawTokens(address tokenAddr) external onlyManager{
        uint _thisTokenBalance = IERC20(tokenAddr).balanceOf(address(this));
        require(IERC20(tokenAddr).transfer(msg.sender, _thisTokenBalance));
    }

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    //---------------------------------------------------------------------------------
    function IsFallOnDebut() public view returns (bool) {
        return xPublicSalePrice < _MTCRedeemPrice;
    }

    function isClosed() public view returns (bool) {
        return now >= _PublicEndTime;
    }
	
    function isRedeemTime() public view returns (bool) {
        return now <= _RedeemTime;
    }
	
	function CheckPublicEndTime() public view returns (uint256) {
        return _PublicEndTime;
    }
	
	function CheckRedeemTime() public view returns (uint256) {
        return _RedeemTime;
    }
	
	function setPublicEndTime(uint xPublicEndTime) public onlyManager{
        _PublicEndTime = xPublicEndTime;
    }
	
	function setRedeemTime(uint xRedeemTime) public onlyManager{
        _RedeemTime = xRedeemTime;
    }
	
	
	function FPCitizenShip() public view returns(address){
        return _FPCitizenShip;
    }
	
	function setFPCitizenShipAddr(address addr) public onlyManager{
        _FPCitizenShip = addr;
    }
	
	function MTCAddr() public view returns(address){
        return _MTCAddr;
    }
	
	function setMTCAddr(address addr) public onlyManager{
        _MTCAddr = addr;
    }
	
	function WBNBAddr() public view returns(address){
        return _WBNBAddr;
    }
	
	function setWBNBAddr(address addr) public onlyManager{
        _WBNBAddr = addr;
    }

	function MTCLPSAddr() public view returns(address){
        return _MTCLPSAddr;
    }
	
	function setMTCLPSAddr(address addr) public onlyManager{
        _MTCLPSAddr = addr;
    }

	function LRAddr() public view returns(address){
        return LiquidityReserve;
    }
	
	function setLRAddr(address addr) public onlyManager{
        LiquidityReserve = addr;
    }
	
	function CheckMTCPrice() public view returns (uint256) {
        return xPublicSalePrice;
    }

	function CheckMTCPriceOnchain() public view returns (uint256) {
		uint _MTCBalance = IERC20(_MTCAddr).balanceOf(_MTCLPSAddr);
		uint _WBNBBalance = IERC20(_WBNBAddr).balanceOf(_MTCLPSAddr);
		uint xMTCPrice = _WBNBBalance.mul(1*10**18).div(_MTCBalance);

        return xMTCPrice.mul(102).div(100);
    }
	
	function CheckMTCRedeemPrice() public view returns (uint256) {
        return _MTCRedeemPrice;
    }

	function getMTCInBNB() public view returns (uint256) {
        return _sMTCInBNB;
    }

	function setMTCPriceOnchain() public onlyManager{
		uint _MTCBalance = IERC20(_MTCAddr).balanceOf(_MTCLPSAddr);
		uint _WBNBBalance = IERC20(_WBNBAddr).balanceOf(_MTCLPSAddr);
		uint xMTCPrice = _WBNBBalance.mul(1*10**18).div(_MTCBalance);

        xPublicSalePrice = xMTCPrice.mul(102).div(100);
    }
	
	function setMTCPrice(uint xMTCPrice) public onlyManager{
        xPublicSalePrice = xMTCPrice;
    }
	
	function setMTCRedeemPrice(uint xMTCRedeemPrice) public onlyManager{
        _MTCRedeemPrice = xMTCRedeemPrice;
    }
	
	function setMTCInBNB(uint xMTCInBNB) public onlyManager{
        _sMTCInBNB = xMTCInBNB;
    }
	
	function getPublicSaleAmount() public view returns (uint256) {
        return PublicSaleAmount;
    }

	function CheckWhiteListMTC(address inputAddr) public view returns (uint256) {
        return _WhiteListMTC[inputAddr];
    }
	
	function CheckRedeemMTC(address inputAddr) public view returns (uint256) {
        return _redeemMTC[inputAddr];
    }
	
	function ChecktotalBuyMTC(address inputAddr) public view returns (uint256) {
        return _totalBuyMTC[inputAddr];
    }

	//--Swap Exact BNB to MTC PublicSale--//
    function PublicSale() external payable{
		require(!isClosed(), "MTC Public Sale : Public sale deadline has arrived.");
		address inputAddr = msg.sender;
		uint _tradeAmount = msg.value;
		uint256 _tokenAmountsMTC = _tradeAmount.mul(getMTCInBNB());
		require(_WhiteListMTC[inputAddr] >= _tokenAmountsMTC && _tokenAmountsMTC != 0, "MTC Public Sale : Whitelist MTC quota has been exhausted.");

		_redeemMTC[inputAddr] = _redeemMTC[inputAddr].add(_tokenAmountsMTC);
		_WhiteListMTC[inputAddr] = _WhiteListMTC[inputAddr].sub(_tokenAmountsMTC);
		_totalBuyMTC[inputAddr] = _totalBuyMTC[inputAddr].add(_tokenAmountsMTC);
		PublicSaleAmount = PublicSaleAmount.add(_tokenAmountsMTC);

		emit PublicSaleMTC(_tradeAmount, _tokenAmountsMTC, true);
    }

    function CheckCSbalanceOf(address addr) public view returns (uint256 tokenId) {
        return IERC20(FPCitizenShip()).balanceOf(addr);
    }
	
    function ChecktokenIDOfOwner(address addr, uint256 index) public view returns (uint256 tokenId) {
        return IERC20(FPCitizenShip()).tokenOfOwnerByIndex(addr, index);
    }
	
    function CheckAllID(address addr) public view returns (uint[] memory) {
        uint _balanceOf = IERC20(FPCitizenShip()).balanceOf(addr);
		uint[] memory tokenIDReturn = new uint[](_balanceOf);
        for (uint i = 0; i < _balanceOf; i++){
		    tokenIDReturn[i] = IERC20(FPCitizenShip()).tokenOfOwnerByIndex(addr, i);
        }
        return tokenIDReturn;
    }

    function CheckpublicMTCOftokenID(uint tokenId) public view returns (uint _TokenpublicMTC) {
        (, uint XpublicMTC, , , ) = IERC20(FPCitizenShip()).CheckTraitData(tokenId);
        return XpublicMTC;
    }

    function CheckAllpublicMTC(address addr) public view returns (uint _AllpublicMTC) {
        uint _balanceOf = IERC20(FPCitizenShip()).balanceOf(addr);
		uint totalpublicMTC = 0;

        for (uint i = 0; i < _balanceOf; i++){
		    uint tokenIDReturn = IERC20(FPCitizenShip()).tokenOfOwnerByIndex(addr, i);
			(, uint XpublicMTC, , , ) = IERC20(FPCitizenShip()).CheckTraitData(tokenIDReturn);
			totalpublicMTC = totalpublicMTC.add(XpublicMTC);
        }
        return totalpublicMTC;
    }
	
	function AddWhiteListMTC() public {
		address inputAddr = msg.sender;
		uint xAllpublicMTC = CheckAllpublicMTC(inputAddr);
		require(!isContract(inputAddr), "MTC Public Sale : Sender is Contract.");
		require(!isClosed(), "MTC Public Sale : Public sale deadline has arrived.");
		require(xAllpublicMTC > 0, "MTC Public Sale : Public sale quota has been exhausted.");
		
		uint _balanceOf = IERC20(FPCitizenShip()).balanceOf(inputAddr);
		_WhiteListMTC[inputAddr] = _WhiteListMTC[inputAddr].add(xAllpublicMTC);
		
        for (uint i = 0; i < _balanceOf; i++){
		    uint tokenIDReturn = IERC20(FPCitizenShip()).tokenOfOwnerByIndex(inputAddr, i);
			(uint8 Xstype, , uint XredeemMTC, address XArinaChain, uint XCitizensQuota) = IERC20(_FPCitizenShip).CheckTraitData(tokenIDReturn);

			IERC20(FPCitizenShip()).setTraitDataGaia(tokenIDReturn, Xstype, 0, XredeemMTC, XArinaChain, XCitizensQuota);
        }
		emit EventAddWhiteListMTC(xAllpublicMTC, true);
    }

    function RedeemBNB(uint _xMTCAmonts) public {
		require(isRedeemTime() && IsFallOnDebut(), "MTC Public Sale : Public sale deadline has not yet arrived.");
		address inputAddr = msg.sender;
		require(!isContract(inputAddr), "MTC Public Sale : Sender is Contract.");
		require(_redeemMTC[inputAddr] >= _xMTCAmonts && _xMTCAmonts != 0, "MTC Public Sale : Redeem MTC quota has been exhausted.");
		uint xRedeemBNB = _xMTCAmonts.div(getMTCInBNB());
        (inputAddr).toPayable().transfer(xRedeemBNB);

		emit EventRedeemBNB(xRedeemBNB, _xMTCAmonts, true);
        _redeemMTC[inputAddr] = _redeemMTC[inputAddr].sub(_xMTCAmonts);
    }
	
    function RedeemAllBNB() public {
		require(isRedeemTime() && IsFallOnDebut(), "MTC Public Sale : Public sale deadline has not yet arrived.");
		address inputAddr = msg.sender;
		require(!isContract(inputAddr), "MTC Public Sale : Sender is Contract.");
		require(_redeemMTC[inputAddr] > 0, "MTC Public Sale : Redeem MTC quota has been exhausted.");
		uint xRedeemBNB = _redeemMTC[inputAddr].div(getMTCInBNB());
        (inputAddr).toPayable().transfer(xRedeemBNB);
		
		emit EventRedeemBNB(xRedeemBNB, _redeemMTC[inputAddr], true);
        _redeemMTC[inputAddr] = 0;
    }

    function WithdrawMTC(uint _xMTCAmonts) public {
		address inputAddr = msg.sender;
		require(!isContract(inputAddr), "MTC Public Sale : Sender is Contract.");
		require(_redeemMTC[inputAddr] >= _xMTCAmonts && _xMTCAmonts != 0, "MTC Public Sale : Redeem MTC quota has been exhausted.");
        require(IERC20(MTCAddr()).transfer(inputAddr, _xMTCAmonts));
		
		emit EventWithdrawMTC(_xMTCAmonts, true);
        _redeemMTC[inputAddr] = _redeemMTC[inputAddr].sub(_xMTCAmonts);
    }
	
    function WithdrawAllMTC() public {
		address inputAddr = msg.sender;
		require(!isContract(inputAddr), "MTC Public Sale : Sender is Contract.");
		require(_redeemMTC[inputAddr] > 0, "MTC Public Sale : Redeem MTC quota has been exhausted.");
        require(IERC20(MTCAddr()).transfer(inputAddr, _redeemMTC[inputAddr]));
		
		emit EventWithdrawMTC(_redeemMTC[inputAddr], true);
        _redeemMTC[inputAddr] = 0;
    }
	
	//--Manager only--//
	function TransferMTCtoLR() public onlyManager{
		require(!isContract(msg.sender), "MTC Public Sale : Sender is Contract.");
		require(!isRedeemTime(), "MTC Public Sale : Public sale deadline has not yet arrived.");
		uint _thisTokenBalance = IERC20(MTCAddr()).balanceOf(address(this));
		require(IERC20(MTCAddr()).transfer(LRAddr(), _thisTokenBalance));
		LRAddr().toPayable().transfer(address(this).balance);
    }

	function destroy() external onlyManager{ 
		require(!isContract(msg.sender), "MTC Public Sale : Sender is Contract.");
        selfdestruct(msg.sender); 
	}
}