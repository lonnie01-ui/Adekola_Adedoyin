import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const NumericApp());

class NumericApp extends StatelessWidget {
  const NumericApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Numeric',
    theme: ThemeData(brightness: Brightness.dark, scaffoldBackgroundColor: const Color(0xFF120008)),
    home: const NumericScreen(),
  );
}

class NumericScreen extends StatefulWidget {
  const NumericScreen({super.key});
  @override
  State<NumericScreen> createState() => _NumericScreenState();
}

class _NumericScreenState extends State<NumericScreen> {
  String _display = '0';
  String _expression = '';
  double _operand = 0;
  String _op = '';
  bool _fresh = false;
  bool _deg = true;

  void _digit(String d) => setState(() {
    if (_fresh){_display=d;_fresh=false;}
    else{_display=_display=='0'?d:_display+d;}
  });
  void _dot() => setState(() {
    if (_fresh){_display='0.';_fresh=false;return;}
    if (!_display.contains('.'))_display+='.';
  });
  void _oper(String op) => setState(() {
    _operand=double.tryParse(_display)??0;
    _op=op;_expression='$_display $op';_fresh=true;
  });
  void _equals() {
    if (_op.isEmpty) return;
    setState(() {
      final b=double.tryParse(_display)??0;
      double r;
      switch(_op){
        case '+':r=_operand+b;break;
        case '−':r=_operand-b;break;
        case '×':r=_operand*b;break;
        case '÷':r=b!=0?_operand/b:double.nan;break;
        default:r=b;
      }
      _expression='$_expression $_display =';
      _display=_fmt(r);_op='';_fresh=true;
    });
  }
  void _clear()=>setState((){_display='0';_expression='';_operand=0;_op='';_fresh=false;});
  void _sign()=>setState((){if(_display=='0'||_display=='Error')return;_display=_display.startsWith('-')?_display.substring(1):'-$_display';});
  void _pct()=>setState((){_display=_fmt((double.tryParse(_display)??0)/100);});
  void _back()=>setState((){
    if(_display=='Error'){_display='0';return;}
    if(_display.length<=1){_display='0';return;}
    _display=_display.substring(0,_display.length-1);
    if(_display=='-')_display='0';
  });
  String _fmt(double r){
    if(r.isNaN||r.isInfinite)return 'Error';
    if(r==r.truncateToDouble()&&r.abs()<1e15)return r.toInt().toString();
    return r.toStringAsFixed(10).replaceAll(RegExp(r'0+\$'),'').replaceAll(RegExp(r'\\.\$'),'');
  }

  void _sci(String fn) => setState(() {
    final x = double.tryParse(_display) ?? 0;
    double r;
    switch (fn) {
      case 'sin':  r = math.sin(_deg ? x*math.pi/180 : x); break;
      case 'cos':  r = math.cos(_deg ? x*math.pi/180 : x); break;
      case 'tan':  r = math.tan(_deg ? x*math.pi/180 : x); break;
      case 'asin': final a1=math.asin(x); r=_deg?a1*180/math.pi:a1; break;
      case 'acos': final a2=math.acos(x); r=_deg?a2*180/math.pi:a2; break;
      case 'atan': final a3=math.atan(x); r=_deg?a3*180/math.pi:a3; break;
      case 'sinh': r = (math.exp(x)-math.exp(-x))/2; break;
      case 'cosh': r = (math.exp(x)+math.exp(-x))/2; break;
      case 'tanh':
        final ts=(math.exp(x)-math.exp(-x))/2;
        final tc=(math.exp(x)+math.exp(-x))/2;
        r = tc!=0 ? ts/tc : double.nan; break;
      case 'log':  r = x>0 ? math.log(x)/math.ln10 : double.nan; break;
      case 'ln':   r = x>0 ? math.log(x)           : double.nan; break;
      case 'sqrt': r = x>=0? math.sqrt(x)           : double.nan; break;
      case 'x²': r = x*x; break;
      case 'x³': r = x*x*x; break;
      case '1/x':  r = x!=0 ? 1/x : double.nan; break;
      case '|x|':  r = x.abs(); break;
      case 'n!':
        if (x<0||x!=x.floorToDouble()){_display='Error';return;}
        r = _fact(x.toInt()).toDouble(); break;
      case 'π': _display=math.pi.toString();_fresh=true;return;
      case 'e':    _display=math.e.toString();_fresh=true;return;
      default: return;
    }
    _display=_fmt(r); _fresh=true;
  });

  void _combo(String type) => setState(() {
    if (_op=='nPr'||_op=='nCr') {
      final rv=double.tryParse(_display)??0;
      final ni=_operand.toInt(); final ri=rv.toInt();
      if (_operand<0||rv<0||rv>_operand){_display='Error';_op='';return;}
      final nF=_fact(ni).toDouble(); final nrF=_fact(ni-ri).toDouble();
      _display=_op=='nPr'?_fmt(nF/nrF):_fmt(nF/(nrF*_fact(ri)));
      _op=''; _fresh=true;
    } else {
      _operand=double.tryParse(_display)??0;
      _op=type; _expression='$_display $type'; _fresh=true;
    }
  });
  int _fact(int n)=>n<=1?1:n*_fact(n-1);


  // ── palette ────────────────────────────────────────────────────────────
  static const _kBg    = Color(0xFF120008);
  static const _kSci   = Color(0xFF880E4F);
  static const _kSciTx = Color(0xFFFF80AB);
  static const _kNum   = Color(0xFF1A000D);
  static const _kOp    = Color(0xFFC2185B);
  static const _kOpTx  = Color(0xFFFF80AB);
  static const _kFn    = Color(0xFF1A000D);
  static const _kEq    = Color(0xFFAD1457);
  static const _kAc    = Color(0xFFB71C1C);

  // ── button widget ───────────────────────────────────────────────────────
  Widget _key(String lbl, VoidCallback fn,
      {Color bg = _kNum, Color fg = Colors.white, int flex = 1, double fs = 15.0}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(1.6),
        child: Material(
          color: bg,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            splashColor: Colors.white12,
            onTap: fn,
            child: Container(
              alignment: Alignment.center,
              child: Text(lbl, style: TextStyle(
                color: fg, fontSize: fs,
                fontWeight: FontWeight.w500, letterSpacing: -0.2)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(List<Widget> k) =>
      Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: k));

  Widget _chip(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: const Color(0xFF6A8C45).withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(3)),
    child: Text(t, style: const TextStyle(
        color: Color(0xFF4A6228), fontSize: 10, fontWeight: FontWeight.bold)),
  );

  // ── scaffold built from state values ────────────────────────────────────
  Widget _scaffold(String disp, String expr, bool deg, VoidCallback toggleDeg) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(child: Column(children: [

        // LCD display
        Container(
          width: double.infinity,
          color: const Color(0xFFCDD8A8),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Row(children: [
              _chip(deg ? 'DEG' : 'RAD'),
              const Spacer(),
              GestureDetector(
                onTap: toggleDeg,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8CA870),
                    borderRadius: BorderRadius.circular(4)),
                  child: Text(deg ? '→ RAD' : '→ DEG',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
            const SizedBox(height: 6),
            Text(expr.isEmpty ? ' ' : expr,
              style: const TextStyle(color: Color(0xFF4A6228), fontSize: 13),
              textAlign: TextAlign.right,
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(disp,
              style: TextStyle(
                color: const Color(0xFF1A2A08), fontSize: 43.0,
                fontWeight: FontWeight.w200, letterSpacing: -1.5),
              textAlign: TextAlign.right,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),

        // Button grid
        Expanded(child: Padding(
          padding: const EdgeInsets.all(3),
          child: Column(children: [
            _row([_key('sin', () => _sci('sin'), bg:_kSci, fg:_kSciTx), _key('cos', () => _sci('cos'), bg:_kSci, fg:_kSciTx), _key('tan', () => _sci('tan'), bg:_kSci, fg:_kSciTx), _key('log', () => _sci('log'), bg:_kSci, fg:_kSciTx), _key('ln', () => _sci('ln'), bg:_kSci, fg:_kSciTx)]),
            _row([_key('asin', () => _sci('asin'), bg:_kSci, fg:_kSciTx, fs:13.0), _key('acos', () => _sci('acos'), bg:_kSci, fg:_kSciTx, fs:13.0), _key('atan', () => _sci('atan'), bg:_kSci, fg:_kSciTx, fs:13.0), _key('√x', () => _sci('sqrt'), bg:_kSci, fg:_kSciTx), _key('x²', () => _sci('x²'), bg:_kSci, fg:_kSciTx)]),
            _row([_key('sinh', () => _sci('sinh'), bg:_kSci, fg:_kSciTx, fs:13.0), _key('cosh', () => _sci('cosh'), bg:_kSci, fg:_kSciTx, fs:13.0), _key('tanh', () => _sci('tanh'), bg:_kSci, fg:_kSciTx, fs:13.0), _key('x³', () => _sci('x³'), bg:_kSci, fg:_kSciTx), _key('1/x', () => _sci('1/x'), bg:_kSci, fg:_kSciTx)]),
            _row([_key('n!', () => _sci('n!'), bg:_kSci, fg:_kSciTx), _key('nPr', () => _combo('nPr'), bg:_kSci, fg:_kSciTx, fs:13.0), _key('nCr', () => _combo('nCr'), bg:_kSci, fg:_kSciTx, fs:13.0), _key('π', () => _sci('π'), bg:_kSci, fg:const Color(0xFFFFD54F)), _key('e', () => _sci('e'), bg:_kSci, fg:const Color(0xFFFFD54F))]),
            _row([
              _key('AC',  _clear,               bg:_kAc, fg:Colors.white),
              _key('⌫', _back,              bg:const Color(0xFF3A1818), fg:const Color(0xFFFF8A80)),
              _key('%',   _pct,                  bg:_kFn, fg:Colors.white70),
              _key('|x|', () => _sci('|x|'),         bg:_kFn, fg:Colors.white60),
              _key('+/−', _sign,            bg:_kFn, fg:Colors.white70),
            ]),
            _row([
              _key('7', () => _digit('7'), fs:20),
              _key('8', () => _digit('8'), fs:20),
              _key('9', () => _digit('9'), fs:20),
              _key('÷', () => _oper('÷'), bg:_kOp, fg:_kOpTx, fs:18),
              _key('×', () => _oper('×'), bg:_kOp, fg:_kOpTx, fs:18),
            ]),
            _row([
              _key('4', () => _digit('4'), fs:20),
              _key('5', () => _digit('5'), fs:20),
              _key('6', () => _digit('6'), fs:20),
              _key('−', () => _oper('−'), bg:_kOp, fg:_kOpTx, fs:18),
              _key('(', () {},                   bg:_kFn, fg:Colors.white54),
            ]),
            _row([
              _key('1', () => _digit('1'), fs:20),
              _key('2', () => _digit('2'), fs:20),
              _key('3', () => _digit('3'), fs:20),
              _key('+', () => _oper('+'), bg:_kOp, fg:_kOpTx, fs:18),
              _key(')', () {},          bg:_kFn, fg:Colors.white54),
            ]),
            _row([
              _key('0',   () => _digit('0'), flex:2, fs:20),
              _key('.',   _dot,          fs:20),
              _key('EXP', () {},            bg:_kFn, fg:Colors.white54, fs:12),
              _key('=',   _equals,       bg:_kEq, fg:Colors.white, fs:22),
            ]),
          ]),
        )),

      ])),
    );
  }

  @override
  Widget build(BuildContext context) =>
    _scaffold(_display, _expression, _deg, () => setState(() => _deg = !_deg));
}

