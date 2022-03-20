/**
 *Submitted for verification at BscScan.com on 2022-03-20
*/

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event LotteryWin(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
}

contract BetToken is Context, IERC20, IERC20Metadata, Ownable {
    using Address for address;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) private _isWhitelisted;

    uint256 private _totalSupply = 0;
    uint256 private constant _initialSupply = 1_000_000_000;

    string  private constant _name     = "Sponsio";
    string  private constant _symbol   = "SPIO";
    uint8   private constant _decimals = 18;

    struct Option {
        string name;
        mapping(address => uint256) participations; 
        mapping(uint => address) participants; 
        uint participantIndex;
    }

    struct Event {
        string title;
        uint idOptionA;
        uint idOptionB;
        uint idOptionDraw;
        string nameOptionA;
        string nameOptionB;
        bool isDrawPossible;
        uint256 createdTimestamp;
        uint256 endTimestamp;
        bool hasEnded;
    }

    mapping(uint => Event) public events;
    uint eventIndex = 0;

    mapping(uint => Option) private options;
    uint optionIndex = 0;

    uint256 private constant PRECISION = 1_000;

    constructor() {
        _mint(_msgSender(), _initialSupply * 10 ** uint256(_decimals));
        emit Transfer(address(0), _msgSender(), _totalSupply);
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function createEvent(string memory title, string memory optionA, string memory optionB, bool isDrawPossible, uint256 eventEndTimestamp) public onlyOwner() {
        Event storage newEvent = events[eventIndex];
        newEvent.title = title;
        newEvent.idOptionA = createOption(optionA);
        newEvent.idOptionB = createOption(optionB);
        newEvent.nameOptionA = optionA;
        newEvent.nameOptionB = optionB;
        newEvent.createdTimestamp = block.timestamp;
        newEvent.endTimestamp = eventEndTimestamp;
        newEvent.hasEnded = false;
        newEvent.isDrawPossible = isDrawPossible;
        if (isDrawPossible) {
            newEvent.idOptionDraw = createOption("Draw");
        }
        eventIndex += 1;
    }

    function createOption(string memory optionName) private onlyOwner() returns (uint) {
        Option storage option = options[optionIndex];
        option.name = optionName;
        option.participantIndex = 0;
        optionIndex += 1;
        return optionIndex - 1;
    }

    function participate(uint eventID, uint option, uint256 amount) public {
        require(eventID < eventIndex, "Cannot participate in non-existing events");
        
        uint256 senderBalance = _balances[_msgSender()];
        require(senderBalance >= amount);

        Event storage ongoingEvent = events[eventID];
        uint optionCount = ongoingEvent.isDrawPossible ? 3 : 2;

        require(option >= 0 && option < optionCount, "Cannot choose invalid option");
        require(!ongoingEvent.hasEnded, "Cannot participate in closed events");
        require(block.timestamp < ongoingEvent.endTimestamp, "Event is already over");

        if (option == 0) {
            participate(_msgSender(), ongoingEvent.idOptionA, amount);
        } else if (option == 1) {
            participate(_msgSender(), ongoingEvent.idOptionB, amount);
        } else if (option == 2) {
            participate(_msgSender(), ongoingEvent.idOptionDraw, amount);
        }

        unchecked {
            _balances[_msgSender()] = senderBalance - amount;
        }
    }

    function participate(address participant, uint optionID, uint256 amount) private {
        Option storage option = options[optionID];
        uint256 participationBefore = option.participations[participant];

        if (participationBefore == 0) {
            option.participations[participant] = amount;
            option.participants[option.participantIndex] = participant;
            option.participantIndex += 1;
        } else {
            option.participations[participant] = participationBefore + amount;
        }
    }

    function getTotalParticipations(uint optionID) public view returns (uint256) {
        Option storage option = options[optionID];
        uint256 participations = 0;

        for (uint index = 0; index < option.participantIndex; index++) {
            address participant = option.participants[index]; 
            participations += option.participations[participant];
        }

        return participations;
    }

    function finishEvent(uint eventID, uint winningOptionIndex) public onlyOwner() returns (uint256) {
        Event storage finishedEvent = events[eventID];
        require(!finishedEvent.hasEnded, "Cannot finish event twice");
        require(block.timestamp >= finishedEvent.endTimestamp, "Cannot finish event before its end"); 

        uint optionCount = finishedEvent.isDrawPossible ? 3 : 2;
        uint[] memory allOptions = new uint[](optionCount);
        allOptions[0] = finishedEvent.idOptionA;
        allOptions[1] = finishedEvent.idOptionB;

        if (finishedEvent.isDrawPossible) {  
            allOptions[2] = finishedEvent.idOptionDraw;
        } 
        require(winningOptionIndex >= 0 && winningOptionIndex < allOptions.length);

        uint winningOptionID = allOptions[winningOptionIndex];
        uint256 winningParticipations = getTotalParticipations(winningOptionID);
        uint256 loosingParticipations = 0;

        for (uint index = 0; index < allOptions.length; index++) {
            if (index != winningOptionIndex) {
                loosingParticipations += getTotalParticipations(allOptions[index]);
            }
        }

        uint256 winPerInvestedToken = loosingParticipations * PRECISION / winningParticipations;
        Option storage winningOption = options[winningOptionID];
        for (uint index = 0; index < winningOption.participantIndex; index++) {
            address winner = winningOption.participants[index];
            uint256 participation = winningOption.participations[winner];
            uint256 profit = winPerInvestedToken * participation / PRECISION;
            _balances[winner] = _balances[winner] + participation + profit;
        }

        finishedEvent.hasEnded = true;
        return 0;
    }

    function cancelEvent(uint eventID) public onlyOwner() {
        Event storage finishedEvent = events[eventID];
        uint optionCount = finishedEvent.isDrawPossible ? 3 : 2;
        require(!finishedEvent.hasEnded, "Cannot cancel event that has ended");

        for (uint optionID = 0; optionID < optionCount; optionID++) {
            Option storage option = options[optionID];
            for (uint index = 0; index < option.participantIndex; index++) {
                address participant = option.participants[index];
                uint256 participation = option.participations[participant];
                _balances[participant] += participation;
            }
        }
    }

    function getEvents() public view returns (Event[] memory) {

        Event[] memory eventList = new Event[](eventIndex);

        for (uint index = 0; index < eventIndex; index++) {
            eventList[index] = events[index];
        }

        return eventList;
    }

    function getEvent(uint eventID) public view returns (Event memory) {
        return events[eventID];
    }
}