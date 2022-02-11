pragma solidity >=0.8.9;

// Galaxy is an Index token for Cosmosium Finance
import "./Ownable.sol";
import "./IERC20.sol";
import "./ERC20.sol";
import "./ReentrancyGuard.sol";
import "./Address.sol";
contract Galaxy is ERC20,Ownable,ReentrancyGuard {
    using Address for address;

    struct Component {
        uint256 baseAmount; // 1 TANE İNDEX TOKENDE BULUNMASI GEREKEN MİKTAR
        IERC20 token;
    }


    mapping(address => bool) public indexedTokens;

    Component[] public components;

    mapping(address => Component) public tokens;

    struct MintAmounts {
        uint256 amount;
        IERC20 token;
    }

    IERC20 public buzz;
    uint256 public mintFee;
    uint256 public burnFee;

    address public feeReceiver;

    bool public initialized;

    event GalaxyMinted(address indexed minter, uint256 amount);
    event GalaxyBurned(address indexed burner, uint256 amount);
    event FeesChanges(address indexed changer, uint256 mintFee, uint256 burnFee);
    event FeeReceiverChanged(address indexed changer, address receiver);

    constructor(string memory _name, string memory _symbol) ERC20(_name,_symbol) {

    }

    function insertComponent(IERC20 _token, uint256 _baseAmount) public onlyOwner {
        require(!initialized, "Index is already initialized");
        require(address(_token) != address(0), "Token address zero");
        components.push(Component({
            token : _token,
            baseAmount : _baseAmount
        }));
    }

    function deleteComponent(uint256 index) public onlyOwner {
        delete components[index];
    }

    function initializeIndex() public onlyOwner {
        // whenever index is initialized no one can change any tokens & ratios on it.
        require(!initialized ,"Index already initialized");

        initialized = true;
    }

    function tokenMintAmounts(uint256 _amount) public view returns(MintAmounts[] memory) { // hata burda
        MintAmounts[] memory mintAmounts = new MintAmounts[](components.length);
        for(uint i = 0; i < components.length; i++) {
            uint256 amount = (_amount * components[i].baseAmount) / 1 ether;
             mintAmounts[i] = MintAmounts({
                amount : amount,
                token : components[i].token
            });
            mintAmounts[i].amount = amount;
            mintAmounts[i].token = components[i].token;
        }

        return mintAmounts;
    }

    function mintAmountsFromToken(IERC20 _token, uint256 _amount) public view returns(MintAmounts[] memory) {
        // returns tokens needed for mint actual token amount
        require(isTokenInserted(_token) == true, "Token is not inserted");
        // find base amount with token
        uint256 tokenBaseRatio;
        for(uint i = 0; i < components.length; i++) {
            if(_token == components[i].token) {
                tokenBaseRatio = components[i].baseAmount;
            }
        }

        // tokenBaseRatio = how much tokens needed to mint 1 galaxy

        uint256 galaxyAmount = (_amount * 1 ether) / tokenBaseRatio; // amount of galaxy can be minted with this

        return tokenMintAmounts(galaxyAmount);
    }

    function isTokenInserted(IERC20 _token) public view returns(bool) {
        for(uint i = 0; i < components.length; i++) {
            if(components[i].token == _token) {
                return true;
            }
        }
        return false;
    }

    function mintGalaxy(uint256 _amount) public nonReentrant notContract{
        require(initialized ,"index not initialized");

        MintAmounts[] memory mintAmounts = tokenMintAmounts(_amount);

        for(uint i = 0;i < mintAmounts.length; i++) {
            uint256 tokenBefore = mintAmounts[i].token.balanceOf(address(this));
            mintAmounts[i].token.transferFrom(msg.sender, address(this),mintAmounts[i].amount);
            uint256 tokenAfter = mintAmounts[i].token.balanceOf(address(this));

            require((tokenAfter - tokenBefore) >= mintAmounts[i].amount, "Token transfer is not enough");
        }
        if(mintFee > 0) {
            uint256 fee = (_amount * mintFee) / 10000;
            _amount = _amount - fee;
            _mint(feeReceiver, fee);
        }
        _mint(msg.sender, _amount);
    }

    function burnGalaxy(uint256 _amount) public nonReentrant notContract{
        require(initialized ,"index not initialized");
        // burn galaxy
        _burn(msg.sender, _amount);
        //adama parasını ver

        if(burnFee > 0) {
            uint256 fee = (_amount * burnFee) / 10000;
            _amount = _amount - fee;
        }

        // Galaxy v1 tokenlerde token kazanımı yapılmadığı için amountlar 1:1 temsil ediliyor.

        MintAmounts[] memory mintAmounts = tokenMintAmounts(_amount);
        // control
        for(uint i = 0; i < mintAmounts.length; i++) {
            mintAmounts[i].token.transfer(msg.sender, mintAmounts[i].amount);
        }
    }

    // Owner functions

    function setFees(uint256 _mintFee, uint256 _burnFee) public onlyOwner {
        require(_mintFee <= 1000, "mint fee too high");
        require(_burnFee <= 1000, "burn fee too high");

        mintFee = _mintFee;
        burnFee = _burnFee;

        emit FeesChanges(msg.sender, _mintFee, _burnFee);
    }

    function setFeeReceiver(address _receiver) public onlyOwner {
        feeReceiver = _receiver;

        emit FeeReceiverChanged(msg.sender, _receiver);
    }

    function _isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    modifier notContract() {
        require(!_isContract(msg.sender), "contract not allowed");
        require(msg.sender == tx.origin, "proxy contract not allowed");
        _;
    }
}