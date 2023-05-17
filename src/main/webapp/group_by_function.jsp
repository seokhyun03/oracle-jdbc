<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
//oracle db 접속
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "HR";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	// sql 전송
	PreparedStatement groupingSetStmt = null;
	ResultSet groupingSetRs = null;
	String groupingSetSql = "select department_id, job_id, count(*) from employees group by grouping sets(department_id, job_id)";
	groupingSetStmt = conn.prepareStatement(groupingSetSql);
	// 위 sql 디버깅
	System.out.println(groupingSetStmt + " <-- group_by_function groupingSetStmt");
	// 전송한 sql 실행값 반환
	// db쿼리 결과셋 모델
	groupingSetRs = groupingSetStmt.executeQuery();
	ArrayList<HashMap<String, Object>> groupingSetList = new ArrayList<HashMap<String, Object>>();
	while(groupingSetRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("부서ID", groupingSetRs.getInt("department_id"));
		m.put("직무ID", groupingSetRs.getString("job_id"));
		m.put("인원수", groupingSetRs.getInt("count(*)"));
		groupingSetList.add(m);
	}
	
	// sql 전송
	PreparedStatement rollupStmt = null;
	ResultSet rollupRs = null;
	String rollupSql = "select department_id, job_id, count(*) from employees group by rollup(department_id, job_id)";
	rollupStmt = conn.prepareStatement(rollupSql);
	// 위 sql 디버깅
	System.out.println(rollupStmt + " <-- group_by_function rollupStmt");
	// 전송한 sql 실행값 반환
	// db쿼리 결과셋 모델
	rollupRs = rollupStmt.executeQuery();
	ArrayList<HashMap<String, Object>> rollupList = new ArrayList<HashMap<String, Object>>();
	while(rollupRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("부서ID", rollupRs.getInt("department_id"));
		m.put("직무ID", rollupRs.getString("job_id"));
		m.put("인원수", rollupRs.getInt("count(*)"));
		rollupList.add(m);
	}
		
	// sql 전송
	PreparedStatement cubeStmt = null;
	ResultSet cubeSetRs = null;
	String cubeSql = "select department_id, job_id, count(*) from employees group by cube(department_id, job_id)";
	cubeStmt = conn.prepareStatement(cubeSql);
	// 위 sql 디버깅
	System.out.println(cubeStmt + " <-- group_by_function cubeStmt");
	// 전송한 sql 실행값 반환
	// db쿼리 결과셋 모델
	cubeSetRs = cubeStmt.executeQuery();
	ArrayList<HashMap<String, Object>> cubeList = new ArrayList<HashMap<String, Object>>();
	while(cubeSetRs.next()) {
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("부서ID", cubeSetRs.getInt("department_id"));
		m.put("직무ID", cubeSetRs.getString("job_id"));
		m.put("인원수", cubeSetRs.getInt("count(*)"));
		cubeList.add(m);
	}
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>group by function</title>
	<!-- Latest compiled and minified CSS -->
	<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">
	
	<!-- Latest compiled JavaScript -->
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
</head>
</head>
<body>
	<div class="row">
		<div class="col-sm">
			<h1>grouping set</h1>
			<table>
				<tr>
					<th>부서ID</th>
					<th>직무ID</th>
					<th>인원수</th>
				</tr>
				<%
					for(HashMap<String, Object> m : groupingSetList) {
				%>
						<tr>
						<%
							if((Integer)(m.get("부서ID")) == 0) {
						%>
								<td></td>
						<%	
							} else {
						%>
								<td><%=m.get("부서ID")%></td>
						<%	
							}
							if(((String)m.get("직무ID")) == null) {
						%>
								<td></td>
						<%	
							} else {
						%>
								<td><%=m.get("직무ID")%></td>
						<%	
							}
						%>
							<td><%=m.get("인원수")%></td>
						</tr>
				<%	
					}
				%>	
			</table>
		</div>
		<div class="col-sm">
			<h1>rollup</h1>
			<table>
				<tr>
					<th>부서ID</th>
					<th>직무ID</th>
					<th>인원수</th>
				</tr>
				<%
					for(HashMap<String, Object> m : rollupList) {
				%>
						<tr>
						<%
							if((Integer)(m.get("부서ID")) == 0) {
						%>
								<td></td>
						<%	
							} else {
						%>
								<td><%=m.get("부서ID")%></td>
						<%	
							}
							if(((String)m.get("직무ID")) == null) {
						%>
								<td></td>
						<%	
							} else {
						%>
								<td><%=m.get("직무ID")%></td>
						<%	
							}
						%>
							<td><%=m.get("인원수")%></td>
						</tr>
				<%	
					}
				%>	
			</table>
		</div>
		<div class="col-sm">
			<h1>cube</h1>
			<table>
				<tr>
					<th>부서ID</th>
					<th>직무ID</th>
					<th>인원수</th>
				</tr>
				<%
					for(HashMap<String, Object> m : cubeList) {
				%>
						<tr>
						<%
							if((Integer)(m.get("부서ID")) == 0) {
						%>
								<td></td>
						<%	
							} else {
						%>
								<td><%=m.get("부서ID")%></td>
						<%	
							}
							if(((String)m.get("직무ID")) == null) {
						%>
								<td></td>
						<%	
							} else {
						%>
								<td><%=m.get("직무ID")%></td>
						<%	
							}
						%>
							<td><%=m.get("인원수")%></td>
						</tr>
				<%	
					}
				%>	
			</table>
		</div>
	</div>
</body>
</html>