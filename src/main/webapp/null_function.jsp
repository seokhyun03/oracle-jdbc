<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	//oracle db 접속
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "gdj66";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// sql 전송
	PreparedStatement nvlStmt = null;
	ResultSet nvlRs = null;
	String nvlSql = "select 이름, nvl(일분기, 0) 일분기 from 실적";
	nvlStmt = conn.prepareStatement(nvlSql);
	// 위 sql 디버깅
	System.out.println(nvlStmt + " <-- null_function nvlStmt");
	// 전송한 sql 실행값 반환
	// db쿼리 결과셋 모델
	nvlRs = nvlStmt.executeQuery();
	ArrayList<HashMap<String, Object>> nvlList = new ArrayList<HashMap<String, Object>>();
	while(nvlRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("이름", nvlRs.getString("이름")); 
		m.put("일분기", nvlRs.getString("일분기"));
		nvlList.add(m);
	}
	
	// sql 전송
	PreparedStatement nvl2Stmt = null;
	ResultSet nvl2Rs = null;
	String nvl2Sql = "select 이름, nvl2(일분기, 'success', 'fail') 일분기 from 실적";
	nvl2Stmt = conn.prepareStatement(nvl2Sql);
	// 위 sql 디버깅
	System.out.println(nvl2Stmt + " <-- null_function nvl2Stmt");
	// 전송한 sql 실행값 반환
	// db쿼리 결과셋 모델
	nvl2Rs = nvl2Stmt.executeQuery();
	ArrayList<HashMap<String, Object>> nvl2List = new ArrayList<HashMap<String, Object>>();
	while(nvl2Rs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("이름", nvl2Rs.getString("이름"));
		m.put("일분기", nvl2Rs.getString("일분기"));
		nvl2List.add(m);
	}
	
	// sql 전송
	PreparedStatement nullifStmt = null;
	ResultSet nullifRs = null;
	String nullifSql = "select 이름, nullif(사분기, 100) 사분기 from 실적";
	nullifStmt = conn.prepareStatement(nullifSql);
	// 위 sql 디버깅
	System.out.println(nullifStmt + " <-- null_function nullifStmt");
	// 전송한 sql 실행값 반환
	// db쿼리 결과셋 모델
	nullifRs = nullifStmt.executeQuery();
	ArrayList<HashMap<String, Object>> nvlifList = new ArrayList<HashMap<String, Object>>();
	while(nullifRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("이름", nullifRs.getString("이름"));
		m.put("사분기", nullifRs.getString("사분기"));
		nvlifList.add(m);
	}
	// sql 전송
	PreparedStatement coalesceStmt = null;
	ResultSet coalesceRs = null;
	String coalesceSql = "select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) 첫실적 from 실적";
	coalesceStmt = conn.prepareStatement(coalesceSql);
	// 위 sql 디버깅
	System.out.println(coalesceStmt + " <-- null_function coalesceStmt");
	// 전송한 sql 실행값 반환
	// db쿼리 결과셋 모델
	coalesceRs = coalesceStmt.executeQuery();
	ArrayList<HashMap<String, Object>> coalesceList = new ArrayList<HashMap<String, Object>>();
	while(coalesceRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("이름", coalesceRs.getString("이름"));
		m.put("첫실적", coalesceRs.getString("첫실적"));
		coalesceList.add(m);
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>nvl</h1>
	<table>
		<tr>
			<th>이름</th>
			<th>일분기</th>
		</tr>
		<%
			for(HashMap<String, Object> m : nvlList) {
		%>
				<tr>
					<td><%=m.get("이름")%></td>
					<td><%=m.get("일분기")%></td>
				</tr>
		<%		
			}
		%>
	</table>
	<h1>nvl2</h1>
	<table>
		<tr>
			<th>이름</th>
			<th>일분기</th>
		</tr>
		<%
			for(HashMap<String, Object> m : nvl2List) {
		%>
				<tr>
					<td><%=m.get("이름")%></td>
					<td><%=m.get("일분기")%></td>
				</tr>
		<%		
			}
		%>
	</table>
	<h1>nullif</h1>
	<table>
		<tr>
			<th>이름</th>
			<th>사분기</th>
		</tr>
		<%
			for(HashMap<String, Object> m : nvlifList) {
		%>
				<tr>
					<td><%=m.get("이름")%></td>
					<td><%=m.get("사분기")%></td>
				</tr>
		<%		
			}
		%>
	</table>
	<h1>coalesce</h1>
	<table>
		<tr>
			<th>이름</th>
			<th>첫실적</th>
		</tr>
		<%
			for(HashMap<String, Object> m : coalesceList) {
		%>
				<tr>
					<td><%=m.get("이름")%></td>
					<td><%=m.get("첫실적")%></td>
				</tr>
		<%		
			}
		%>
	</table>
</body>
</html>