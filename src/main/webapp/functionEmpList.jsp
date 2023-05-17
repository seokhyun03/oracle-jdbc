<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%
	/*
		select 
		    last_name, substr(last_name, 1, 3),
		    salary, round(salary/12, 2),
		    hire_date, extract(year from hire_date) 
		from employees;
	*/
	// 현재페이지
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	//oracle db 접속
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dburl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "HR";
	String dbpw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dburl, dbuser, dbpw);
	
	PreparedStatement totalRowStmt = null;
	ResultSet totalRowRs = null;
	String totalRowSql = "select count(*) from employees";
	totalRowStmt = conn.prepareStatement(totalRowSql);
	totalRowRs = totalRowStmt.executeQuery();
	
	int rowPerPage = 10;
	int beginRow = (currentPage-1) * rowPerPage + 1;
	int endRow = beginRow + rowPerPage - 1;
	int totalRow = 0;
	if(totalRowRs.next()) {
		totalRow = totalRowRs.getInt(1);
	}
	if(endRow > totalRow) {
		endRow = totalRow;
	}
	int lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0) {
		lastPage = lastPage + 1;
	}
	
	// sql 전송
	PreparedStatement stmt = null;
	ResultSet rs = null;
	String sql = "select 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도 from (select rownum 번호, last_name 이름, substr(last_name, 1, 1) 이름첫글자, salary 연봉, round(salary/12, 2) 급여, hire_date 입사날짜, extract(year from hire_date) 입사년도 from employees) where 번호 between ? and ?";
	stmt = conn.prepareStatement(sql);
	stmt.setInt(1,beginRow);
	stmt.setInt(2,endRow);
	// 위 sql 디버깅
	System.out.println(stmt + " <-- functionEmpList stmt");
	// 전송한 sql 실행값 반환
	// db쿼리 결과셋 모델
	rs = stmt.executeQuery();
	
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()) {
		HashMap<String, Object> m = new HashMap<>();
		m.put("번호",rs.getInt("번호"));
		m.put("이름",rs.getString("이름"));
		m.put("이름첫글자",rs.getString("이름첫글자"));
		m.put("연봉",rs.getInt("연봉"));
		m.put("급여",rs.getDouble("급여"));
		m.put("입사날짜",rs.getString("입사날짜"));
		m.put("입사년도",rs.getInt("입사년도"));
		list.add(m);
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<table border="1">
		<tr>
			<td>번호</td>
			<td>이름</td>
			<td>이름첫글자</td>
			<td>연봉</td>
			<td>급여</td>
			<td>입사날짜</td>
			<td>입사년도</td>
		</tr>
		<%
			for(HashMap<String, Object> m : list) {
		%>
				<tr>
					<td><%=(Integer)m.get("번호")%></td>
					<td><%=(String)m.get("이름")%></td>
					<td><%=(String)m.get("이름첫글자")%></td>
					<td><%=(Integer)m.get("연봉")%></td>
					<td><%=(Double)m.get("급여")%></td>
					<td><%=(String)m.get("입사날짜")%></td>
					<td><%=(Integer)m.get("입사년도")%></td>
				</tr>
		<%		
			}
		%>
	</table>
	<%
		// 페이지 네비게이션 페이징
		int pagePerPage = 10;
		int minPage = (currentPage-1) / pagePerPage * pagePerPage + 1;
		int maxPage = minPage + pagePerPage - 1;
		if(maxPage > lastPage) {
			maxPage = lastPage;
		}
		
		if(minPage>1) {
	%>
			<a href="<%=request.getContextPath()%>/functionEmpList.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
	<%			
		}
		for(int i = minPage; i<=maxPage; i=i+1) {
			if(i == currentPage) {
	%>	
			<%=i%>
	<%			
			}else {
	%>	
				<a href="<%=request.getContextPath()%>/functionEmpList.jsp?currentPage=<%=i%>"><%=i%></a>
	<%				
			}
		}
		if(maxPage != lastPage) {
	%>
			<a href="<%=request.getContextPath()%>/functionEmpList.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
	<%	
		}
	%>
</body>
</html>