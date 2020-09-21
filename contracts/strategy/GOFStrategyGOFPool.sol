pragma solidity ^0.5.16;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + (((a % 2) + (b % 2)) / 2);
    }
}

library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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

    function div( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod( uint256 a, uint256 b, string memory errorMessage ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}

    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require( address(this).balance >= amount, "Address: insufficient balance" );

        (bool success, ) = recipient.call.value(amount)("");
        require( success, "Address: unable to send value, recipient may have reverted" );
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function mint(address account, uint256 amount) external;
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom( address sender, address recipient, uint256 amount ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval( address indexed owner, address indexed spender, uint256 value );
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer( IERC20 token, address to, uint256 value ) internal { callOptionalReturn( token, abi.encodeWithSelector(token.transfer.selector, to, value) ); }

    function safeTransferFrom( IERC20 token, address from, address to, uint256 value ) internal {
        callOptionalReturn( token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value) );
    }

    function safeApprove( IERC20 token, address spender, uint256 value ) internal {
        require( (value == 0) || (token.allowance(address(this), spender) == 0), "SafeERC20: approve from non-zero to non-zero allowance" );
        callOptionalReturn( token, abi.encodeWithSelector(token.approve.selector, spender, value) );
    }

    function safeIncreaseAllowance( IERC20 token, address spender, uint256 value ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add( value );
        callOptionalReturn( token, abi.encodeWithSelector( token.approve.selector, spender, newAllowance ) );
    }

    function safeDecreaseAllowance( IERC20 token, address spender, uint256 value ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub( value, "SafeERC20: decreased allowance below zero" );
        callOptionalReturn( token, abi.encodeWithSelector( token.approve.selector, spender, newAllowance ) );
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require( abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed" );
        }
    }
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor( string memory name, string memory symbol, uint8 decimals ) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

/*

 A strategy must implement the following calls;
 
 - deposit()
 - withdraw(address) must exclude any tokens used in the yield - Controller role - withdraw should return to Controller
 - withdraw(uint) - Controller | Vault role - withdraw should always return to vault
 - withdrawAll() - Controller | Vault role - withdraw should always return to vault
 - balanceOf()
 
 Where possible, strategies must remain as immutable as possible, instead of updating variables, we update the contract by linking it in the controller
 
*/

/**
 * Uniswap trade Interface
 */
interface Uniswap {
    function swapExactTokensForTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline) external returns (uint[] memory amounts);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens( uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline ) external;
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

/**
 * GOF Pool Interface
 */
interface IGOFPool{
    function earned(address account) external view returns (uint256);
    function stake(uint256 amount) external; 
    function withdraw(uint256 amount) external;
    function exit() external;
    function getReward() external;
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
}

/**
 * @dev Vaults Token StrategyController Interface
 */
interface IGOFStrategyController {
    function withdraw(address, uint256) external;
    function balanceOf(address) external view returns (uint256);
    function earn(address, uint256) external;
    function rewards() external view returns (address);
    function vaults(address) external view returns (address);
}

/**
 * @dev Gof Vault Interface
 */
interface IGOFVault{
    function distributeReward(uint256 amount) external;
}

/**
 * GOF Pool GOFStrategy
 */
contract GOFStrategyGOFPool {
    using SafeERC20 for IERC20;
    using Address for address;
    using SafeMath for uint256;
    
    address public pool;
    address public output;
    string public getName;

    address constant public gof = address(0x9B101A705e19D291ce99d5e92d0a3aC1082c326f);
    address constant public unirouter = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    uint public fee = 100;
    uint public burnfee = 300;
    uint public callfee = 100;
    uint constant public max = 10000;
    
    uint public withdrawalFee = 0;
    uint constant public withdrawalMax = 10000;

    address public governance;
    address public controller;

    address  public want;
    
    address[] public swapRouting;

    constructor(address _controller, address _output, address _pool, address _want) public {
        governance = tx.origin;
        controller = _controller;
        output = _output;
        pool = _pool;
        want = _want;
        getName = string(
            abi.encodePacked("golff:Strategy:", 
                abi.encodePacked(ERC20Detailed(want).name(),
                    abi.encodePacked(":",ERC20Detailed(output).name())
                )
            ));
        init(); 
        //grap->ycrv -> weth->gof
        //swapRouting = [output,ycrv,weth,gof];
    }

    //Init method
    function init() public{
        // IERC20(output).safeApprove(unirouter, uint(-1));
    }

    // Deposit all want funds into the pool
    function deposit() external {
        uint _want = IERC20(want).balanceOf(address(this));
        if (_want > 0) {
            IERC20(want).safeApprove(pool, 0);
            IERC20(want).safeApprove(pool, IERC20(want).balanceOf(address(this)));
            IGOFPool(pool).stake(IERC20(want).balanceOf(address(this)));
        }
    }
    
    // Controller only function for creating additional rewards from dust
    function withdraw(IERC20 _asset) external returns (uint balance) {
        require(msg.sender == controller, "Golff:!controller");
        require(want != address(_asset), "Golff:want");
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(controller, balance);
    }
    
    // Withdraw partial funds, normally used with a vault withdrawal
    function withdraw(uint _amount) external {
        require(msg.sender == controller, "Golff:!controller");
        uint _balance = IERC20(want).balanceOf(address(this));
        
        //检查当前额度是否足够提现
        if (_balance < _amount) {
            _amount = _withdrawSome(_amount.sub(_balance));
            _amount = _amount.add(_balance);
        }
        
        //收取提现手续费
        uint _fee = 0;
        if (withdrawalFee>0){
            _fee = _amount.mul(withdrawalFee).div(withdrawalMax);        
            IERC20(want).safeTransfer(IGOFStrategyController(controller).rewards(), _fee);
        }

        //将资金转入Vault
        address _vault = IGOFStrategyController(controller).vaults(address(want));
        require(_vault != address(0), "Golff:!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, _amount);
    }
    
    // Withdraw all funds, normally used when migrating strategies
    function withdrawAll() public returns (uint balance) { 
        require(msg.sender == controller||msg.sender==governance, "Golff:!controller");
        _withdrawAll();
        balance = IERC20(want).balanceOf(address(this));
        
        address _vault = IGOFStrategyController(controller).vaults(address(want));
        require(_vault != address(0), "Golff:!vault"); // additional protection so we don't burn the funds
        IERC20(want).safeTransfer(_vault, balance);
        
    }
    
    // Set new pool
    function setNewPool(address _output, address _pool) public{
        require(msg.sender == governance, "Golff:!governance");
        harvest();
        withdrawAll();
        output = _output;
        pool = _pool;
        getName = string(
            abi.encodePacked("golff:Strategy:", 
                abi.encodePacked(ERC20Detailed(want).name(),
                    abi.encodePacked(":",ERC20Detailed(output).name())
                )
            ));

    }
    
    function harvest() public {
        require(!Address.isContract(msg.sender),"Golff:!contract");
        IGOFPool(pool).getReward(); 
        address _vault = IGOFStrategyController(controller).vaults(address(want));
        require(_vault != address(0), "Golff:!vault"); // additional protection so we don't burn the funds


        uint b = IERC20(gof).balanceOf(address(this));
        if (b > 0) {
            uint _fee = b.mul(fee).div(max);
            uint _callfee = b.mul(callfee).div(max);
            uint _burnfee = b.mul(burnfee).div(max);
            IERC20(gof).safeTransfer(IGOFStrategyController(controller).rewards(), _fee); 
            IERC20(gof).safeTransfer(msg.sender, _callfee); //call fee 1%
            IERC20(gof).safeTransfer(address(0x6666666666666666666666666666666666666666), _burnfee); //burn fee 3%

            IERC20(gof).safeApprove(_vault, 0);
            IERC20(gof).safeApprove(_vault, IERC20(gof).balanceOf(address(this)));
            IGOFVault(_vault).distributeReward(IERC20(gof).balanceOf(address(this)));
        }
    }
    
    function _withdrawAll() internal { 
        IGOFPool(pool).exit();
    }

    function _withdrawSome(uint256 _amount) internal returns (uint) {
        IGOFPool(pool).withdraw(_amount);
        return _amount;
    }
    
    function balanceOf() public view returns (uint) {
        return IGOFPool(pool).balanceOf(address(this));
    }

    function balanceOfPendingReward() public view returns(uint){ 
        return IGOFPool(pool).earned(address(this));
    }
    
    function setGovernance(address _governance) external {
        require(msg.sender == governance, "Golff:!governance");
        governance = _governance;
    }
    
    function setController(address _controller) external {
        require(msg.sender == governance, "Golff:!governance");
        controller = _controller;
    }

    function setFee(uint256 _fee) external{
        require(msg.sender == governance, "Golff:!governance");
        fee = _fee;
    }

    function setCallFee(uint256 _fee) external{
        require(msg.sender == governance, "Golff:!governance");
        callfee = _fee;
    } 

    function setBurnFee(uint256 _fee) external{
        require(msg.sender == governance, "Golff:!governance");
        burnfee = _fee;
    }

    function setWithdrawalFee(uint _withdrawalFee) external {
        require(msg.sender == governance, "Golff:!governance");
        require(_withdrawalFee <=100,"fee >= 1%"); //max:1%
        withdrawalFee = _withdrawalFee;
    }

    function setSwapRouting(address[] memory _path) public{
        require(msg.sender == governance, "Golff:!governance");
        swapRouting = _path;
    }
}